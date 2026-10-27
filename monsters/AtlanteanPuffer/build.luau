--!nocheck
-- Atlantean Pufferfish: a shy, jumpy little pufferfish from the sunken city.
-- A chubby stepped-voxel ball (teal body, dark-teal back with spots, cream
-- marble belly with stepped plates, an orichalcum gold belt), short gold block
-- spines all over (each spine is its own bone so they POP out when it puffs),
-- huge googly eyes with turquoise glints, worried brows, blushing cheeks, a
-- tiny pouty "o" mouth, little fluttering fins (big enough to hide behind) and
-- a tilted marble Ionic column-capital "crown" with a glowing rune tile.
-- The body is split into 6 panels (top / belly / sides / rear / face) on their
-- own bones: the motion pushes them outward to INFLATE the fish while hidden
-- "fill" blocks appear behind them. Hidden extras for the personality: a big
-- blush with "///" lines, half-lids, startled tiny pupils, a "!" mark, a
-- sweat drop, and voxel bubbles for the "pfft" deflate.
return {
	DisplayName = "Atlantean Pufferfish",
	Rarity = "Common",
	Element = "Atlantis",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		-- palette
		local TEAL, DTEAL, DEEP = "#2fb5a8", "#1d7f78", "#135a55"
		local LTEAL, FINC = "#5fd3c6", "#8ae8dc"
		local CREAM, MARBLE, MSHADE = "#f3e6c8", "#fbf7ee", "#d9ccb0"
		local GOLD, DGOLD = "#e9b53c", "#b07d1e"
		local LIP, LIPD, MOUTH = "#ff8a8a", "#e2606a", "#2a0f1a"
		local BLUSH, BLUSHD = "#ff9db5", "#f0668c"
		local PUPIL, EYEW = "#10141c", "#ffffff"
		local BUBC, SWEAT = "#c9f6ff", "#9fe8ff"
		local TURQ, NGOLD = "#3ff0e0", "#ffe27a" -- the two small neon accents
		local NEON = { mat = "Neon" }

		local C = v(0, 6.8, 0) -- body centre
		local function rp(x, y, z) return C + v(x, y, z) end
		local function at(x, y, z, rx, ry, rz) return CFrame.new(rp(x, y, z)) * ang(rx or 0, ry or 0, rz or 0) end

		------------------------------------------------------------------
		-- BODY core (stepped ball = core cube + 6 panels on their own bones)
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", C)
		B:block(body, v(5.6, 3.1, 5.6), at(0, 1.25, 0), TEAL)
		B:block(body, v(5.6, 2.55, 5.6), at(0, -1.55, 0), CREAM)
		-- hidden inflated fill (revealed while puffed): fills the stepped
		-- notches between the pushed-out panels so the puffed ball stays round
		B:block(body, v(8.0, 4.3, 8.0), at(0, 1.85, 0), TEAL, { tr = 1, name = "FillTop" })
		B:block(body, v(7.95, 3.7, 7.95), at(0, -2.15, 0), CREAM, { tr = 1, name = "FillBot" })
		B:block(body, v(8.1, 0.35, 8.1), at(0, -0.3, 0), GOLD, { tr = 1, name = "FillBelt" })
		local fx = B:block(body, v(6, 6, 6), at(0, 0, 0), TEAL, { tr = 1, name = "BodyFX" })
		B:emitter(fx, "bubble", { name = "AmbientBubbles", color = { "#ffffff", BUBC }, rate = 2.5, size = { 0.25, 0.4, 0.5 } })
		B:emitter(fx, "burst", { name = "PuffBurst", color = { "#ffffff", NGOLD, TURQ }, speed = { 10, 18 }, size = { 1.0, 0.6, 0 } })
		B:emitter(fx, "leaf", { name = "MarbleChips", color = { MARBLE, CREAM, GOLD }, rate = 0, size = { 0.5, 0.5, 0.3 }, speed = { 6, 11 }, life = { 1.0, 1.8 }, spread = 180, accel = { 0, -14, 0 } })
		B:light(fx, { name = "PuffLight", color = TURQ, brightness = 0.3, range = 14 })

		-- TOP panel: dark teal back with deep spots
		local top = B:bone("Top", "Body", rp(0, 2.8, 0))
		B:block(top, v(5.4, 2.8, 5.4), at(0, 2.4, 0), DTEAL)
		B:block(top, v(0.9, 0.2, 0.9), at(1.3, 3.85, 1.2), DEEP)
		B:block(top, v(0.7, 0.2, 0.7), at(-1.5, 3.85, 0.3), DEEP)
		B:block(top, v(0.6, 0.2, 0.6), at(0.4, 3.85, 2.0), DEEP)
		B:block(top, v(0.6, 0.2, 0.6), at(-0.9, 3.85, -1.8), DEEP)

		-- BELLY panel: cream with stepped marble plates and a gold trim
		local belly = B:bone("Belly", "Body", rp(0, -2.8, 0))
		B:block(belly, v(5.4, 2.8, 5.4), at(0, -2.4, 0), CREAM)
		B:block(belly, v(3.8, 0.3, 1.5), at(0, -3.9, -1.3), MARBLE)
		B:block(belly, v(3.2, 0.3, 1.3), at(0, -3.9, 0.3), MSHADE)
		B:block(belly, v(4.2, 0.3, 0.4), at(0, -3.9, 1.6), GOLD)

		-- SIDE panels: teal over cream, gold belt, deep spots
		B:sym(function(side)
			local s = B:bone("Side" .. side, "Body", rp(2.8, 0, 0))
			B:block(s, v(2.8, 3.0, 5.4), at(2.4, 1.2, 0), TEAL)
			B:block(s, v(2.8, 2.4, 5.4), at(2.4, -1.5, 0), CREAM)
			B:block(s, v(0.2, 0.35, 5.4), at(3.85, -0.3, 0), GOLD)
			B:block(s, v(0.2, 0.9, 0.9), at(3.85, 1.6, 0.9), DEEP)
			B:block(s, v(0.2, 0.6, 0.6), at(3.85, 2.2, -1.2), DEEP)
			B:block(s, v(0.2, 0.6, 0.6), at(3.85, 0.7, 2.0), DEEP)
		end)

		-- barnacles on the lower left flank
		B:block("SideL", v(0.4, 0.8, 0.9), at(-3.9, -1.6, 1.4), MSHADE)
		B:block("SideL", v(0.2, 0.35, 0.35), at(-4.12, -1.5, 1.4), DEEP)
		B:block("SideL", v(0.35, 0.55, 0.6), at(-3.88, -1.9, 0.4), MSHADE)

		-- REAR panel
		local rear = B:bone("Rear", "Body", rp(0, 0, 2.8))
		B:block(rear, v(5.4, 3.0, 2.8), at(0, 1.2, 2.4), TEAL)
		B:block(rear, v(5.4, 2.4, 2.8), at(0, -1.5, 2.4), CREAM)
		B:block(rear, v(5.4, 0.35, 0.2), at(0, -0.3, 3.85), GOLD)
		B:block(rear, v(0.8, 0.8, 0.2), at(-1.4, 1.7, 3.85), DEEP)

		------------------------------------------------------------------
		-- FACE panel: googly eyes, worried brows, pouty lips, chin plates
		------------------------------------------------------------------
		local face = B:bone("Face", "Body", rp(0, 0, -2.8))
		B:block(face, v(5.4, 3.0, 2.8), at(0, 1.2, -2.4), TEAL)
		B:block(face, v(5.4, 2.4, 2.8), at(0, -1.5, -2.4), CREAM)
		B:block(face, v(3.0, 0.5, 1.0), at(0, -2.35, -3.55), MARBLE) -- stepped chin plates
		B:block(face, v(2.0, 0.45, 1.0), at(0, -2.8, -3.5), MSHADE)

		B:sym(function(side)
			local eye = B:bone("Eye" .. side, "Face", rp(1.55, 0.7, -3.6))
			B:block(eye, v(2.9, 3.1, 1.2), at(1.55, 0.7, -3.55), DEEP) -- dark rim
			B:block(eye, v(2.6, 2.8, 1.6), at(1.55, 0.7, -3.6), EYEW)
			local pup = B:bone("Pupil" .. side, "Eye" .. side, rp(1.55, 0.55, -4.4))
			B:block(pup, v(1.3, 1.6, 0.2), at(1.55, 0.5, -4.48), PUPIL, { name = "PupilBig" .. side })
			B:block(pup, v(0.6, 0.7, 0.2), at(1.55, 0.6, -4.49), PUPIL, { tr = 1, name = "PupilSmall" .. side })
			-- eyelids (hidden): full blink lid + embarrassed half lid
			local lid = B:bone("Lid" .. side, "Eye" .. side, rp(1.55, 0.7, -3.6))
			B:block(lid, v(2.75, 2.95, 1.9), at(1.55, 0.7, -3.75), TEAL, { tr = 1, name = "Lid" .. side })
			B:block(lid, v(1.9, 0.45, 0.3), at(1.55, 0.3, -4.8), DEEP, { tr = 1, name = "Lash" .. side })
			B:block(lid, v(0.45, 0.5, 0.3), at(0.6, 0.65, -4.81), DEEP, { tr = 1, name = "LashA" .. side })
			B:block(lid, v(0.45, 0.5, 0.3), at(2.5, 0.65, -4.81), DEEP, { tr = 1, name = "LashB" .. side })
			B:block(lid, v(2.75, 1.3, 1.9), at(1.55, 1.5, -3.76), TEAL, { tr = 1, name = "HalfLid" .. side })
			B:block(lid, v(2.85, 0.35, 0.3), at(1.55, 0.85, -4.81), DEEP, { tr = 1, name = "HalfLash" .. side })
			-- worried brow (inner end raised)
			local brow = B:bone("Brow" .. side, "Face", rp(1.55, 2.6, -3.9))
			B:block(brow, v(2.3, 0.55, 1.3), at(1.55, 2.65, -3.8, 0, 0, -18), DEEP)
		end)
		-- turquoise glints (same side on both eyes, so not mirrored)
		B:block("PupilR", v(0.45, 0.45, 0.1), at(1.85, 0.95, -4.6), TURQ, { mat = "Neon", name = "GlintR" })
		B:block("PupilL", v(0.45, 0.45, 0.1), at(-1.25, 0.95, -4.6), TURQ, { mat = "Neon", name = "GlintL" })

		-- tiny pouty "o" lips
		local lips = B:bone("Lips", "Face", rp(0, -1.3, -3.9))
		B:block(lips, v(1.5, 0.45, 0.7), at(0, -0.9, -4.1), LIP)
		B:block(lips, v(1.5, 0.55, 0.75), at(0, -1.75, -4.12), LIPD)
		B:block(lips, v(0.7, 0.45, 0.3), at(0, -1.32, -3.95), MOUTH)
		B:sym(function()
			B:block(lips, v(0.45, 0.5, 0.7), at(0.55, -1.32, -4.1), LIP)
		end)
		local mfx = B:block(lips, v(0.8, 0.8, 0.8), at(0, -1.3, -4.8), BUBC, { tr = 1, name = "MouthFX" })
		B:emitter(mfx, "bubble", { name = "Pfft", color = { "#ffffff", BUBC }, rate = 0, size = { 0.5, 0.8, 0.9 }, speed = { 6, 12 }, spread = 30, dir = "Front", life = { 0.8, 1.5 } })

		-- cheeks with blush (big embarrassed blush + "///" lines hidden)
		B:sym(function(side)
			local ck = B:bone("Cheek" .. side, "Body", rp(2.6, -1.4, -2.6))
			B:block(ck, v(1.6, 1.8, 2.4), at(3.0, -1.5, -2.7), CREAM)
			B:block(ck, v(1.3, 0.6, 0.1), at(2.95, -1.25, -3.95), BLUSH)
			B:block(ck, v(1.6, 0.85, 0.1), at(2.95, -1.25, -4.03), BLUSH, { tr = 1, name = "BlushBig" .. side })
			for k = 1, 3 do
				B:block(ck, v(0.14, 0.6, 0.1), at(2.45 + k * 0.3, -1.25, -4.1, 0, 0, -25), BLUSHD, { tr = 1, name = "BlushLine" .. side .. k })
			end
		end)

		------------------------------------------------------------------
		-- FINS: pectorals (base + fan tip, big enough to hide behind)
		------------------------------------------------------------------
		B:sym(function(side)
			local FR = CFrame.new(rp(3.9, 0.4, -2.2)) * ang(0, -55, 0)
			local fin = B:bone("Fin" .. side, "Side" .. side, FR)
			B:block(fin, v(1.0, 1.4, 1.0), FR * CFrame.new(0.1, 0, 0), TEAL)
			B:block(fin, v(2.2, 1.2, 0.5), FR * CFrame.new(1.2, 0, 0), LTEAL)
			B:block(fin, v(1.9, 0.3, 0.55), FR * CFrame.new(1.3, 0.65, 0), GOLD)
			local tipF = FR * CFrame.new(2.2, 0, 0)
			local tip = B:bone("FinTip" .. side, "Fin" .. side, tipF)
			B:block(tip, v(1.2, 2.2, 0.45), FR * CFrame.new(2.75, 0.1, 0), FINC)
			B:block(tip, v(1.0, 2.8, 0.4), FR * CFrame.new(3.75, 0.15, 0), LTEAL)
			B:block(tip, v(0.5, 2.8, 0.45), FR * CFrame.new(4.45, 0.15, 0), GOLD)
			B:trail(tip, (FR * CFrame.new(4.6, 1.4, 0)).Position, (FR * CFrame.new(4.6, -1.1, 0)).Position,
				{ name = "FinTrail" .. side, color = { "#ffffff", TURQ }, life = 0.25, trans = { 0.5, 1 } })
		end)

		-- dorsal + anal fins (buzzing)
		local dorsal = B:bone("Dorsal", "Top", rp(0, 3.6, 2.0))
		B:block(dorsal, v(0.45, 1.2, 1.8), at(0, 4.2, 2.2), FINC)
		B:block(dorsal, v(0.4, 0.8, 1.2), at(0, 4.9, 2.6), LTEAL)
		B:block(dorsal, v(0.45, 0.5, 0.7), at(0, 5.4, 3.0), GOLD)
		local anal = B:bone("Anal", "Belly", rp(0, -3.6, 2.0))
		B:block(anal, v(0.45, 1.0, 1.6), at(0, -4.1, 2.3), FINC)
		B:block(anal, v(0.45, 0.5, 0.8), at(0, -4.75, 2.7), GOLD)

		-- TAIL: peduncle + forked fan with gold lobes and neon tips
		local tail = B:bone("Tail", "Rear", rp(0, 0.3, 3.6))
		B:block(tail, v(2.0, 2.2, 1.8), at(0, 0.3, 4.3), TEAL)
		B:block(tail, v(1.6, 0.3, 1.6), at(0, 1.5, 4.3), DTEAL)
		B:block(tail, v(1.6, 0.3, 1.6), at(0, -0.9, 4.3), CREAM)
		local tfin = B:bone("TailFin", "Tail", rp(0, 0.3, 5.0))
		B:block(tfin, v(0.6, 2.6, 0.9), at(0, 0.3, 5.4), DTEAL)
		B:block(tfin, v(0.5, 3.6, 0.9), at(0, 0.3, 6.2), FINC)
		B:block(tfin, v(0.45, 4.6, 1.0), at(0, 0.3, 7.0), LTEAL)
		B:block(tfin, v(0.5, 1.4, 0.8), at(0, 1.9, 7.8), GOLD)
		B:block(tfin, v(0.5, 1.4, 0.8), at(0, -1.3, 7.8), GOLD)
		B:block(tfin, v(0.4, 0.4, 0.4), at(0, 2.7, 8.25), TURQ, NEON)
		B:block(tfin, v(0.4, 0.4, 0.4), at(0, -2.1, 8.25), TURQ, NEON)
		B:trail(tfin, rp(0, 2.7, 8.3), rp(0, -2.1, 8.3), { name = "TailTrail", color = { "#ffffff", TURQ }, life = 0.25, trans = { 0.55, 1 } })

		------------------------------------------------------------------
		-- CROWN: little tilted marble Ionic capital with a rune tile
		------------------------------------------------------------------
		local CR = CFrame.new(rp(0, 3.8, -0.2)) * ang(0, 0, -9)
		local crown = B:bone("Crown", "Top", CR)
		local function cb(sx, sy, sz, x, y, z, col, opts, rz)
			return B:block(crown, v(sx, sy, sz), CR * CFrame.new(x, y, z) * ang(0, 0, rz or 0), col, opts)
		end
		cb(1.8, 1.0, 1.8, 0, 0.45, 0, MARBLE) -- drum
		cb(0.2, 0.9, 0.1, -0.45, 0.45, -0.92, MSHADE) -- fluting
		cb(0.2, 0.9, 0.1, 0.45, 0.45, -0.92, MSHADE)
		cb(2.1, 0.3, 2.1, 0, 1.05, 0, GOLD) -- orichalcum band
		cb(2.6, 0.5, 2.0, 0, 1.4, 0, MARBLE) -- echinus
		cb(3.6, 0.5, 2.2, 0, 1.9, 0, MARBLE) -- abacus
		cb(1.0, 0.75, 0.15, 0, 1.45, -1.05, DEEP) -- rune tile
		cb(0.6, 0.15, 0.1, 0, 1.6, -1.13, TURQ, NEON)
		cb(0.15, 0.45, 0.1, 0, 1.38, -1.13, TURQ, NEON)
		B:sym(function()
			-- volute scrolls (stepped) with gold eyes
			B:block(crown, v(0.8, 1.0, 2.3), CR * CFrame.new(1.65, 1.35, 0), CREAM)
			B:block(crown, v(0.5, 0.5, 2.35), CR * CFrame.new(1.7, 1.05, 0), MSHADE)
			B:block(crown, v(0.35, 0.35, 0.1), CR * CFrame.new(1.65, 1.35, -1.2), GOLD)
		end)
		-- a little coral sprig growing on the ruin + a seaweed strand
		cb(0.4, 0.7, 0.4, 1.1, 2.45, 0.5, "#ff7a5c")
		cb(0.35, 0.5, 0.35, 1.4, 2.85, 0.5, "#ff9a6e", nil, -30)
		cb(0.3, 0.45, 0.3, 0.85, 2.9, 0.5, "#ff7a5c", nil, 25)
		cb(0.3, 1.0, 0.3, -1.85, 0.75, -0.6, "#3fae6a")
		cb(0.3, 0.6, 0.3, -1.95, 0.0, -0.6, "#2f8f55", nil, 15)
		local gem = cb(0.55, 0.55, 0.55, 0, 2.45, 0, TURQ, { mat = "Neon", name = "CrownGem" }, 45)
		B:emitter(gem, "sparkle", { name = "Sparkle", color = { "#ffffff", NGOLD, TURQ }, rate = 3 })

		------------------------------------------------------------------
		-- SPINES: short gold block spikes, one bone each (pop out on puff)
		-- {name, parent, rel pos (right side), dir, mirrored}
		------------------------------------------------------------------
		local SPINES = {
			{ "SpTopA", "Top", { 1.6, 3.8, 1.4 }, { 0.35, 1, 0.3 }, true },
			{ "SpTopB", "Top", { 1.6, 3.8, -1.3 }, { 0.35, 1, -0.3 }, true },
			{ "SpEdgeU", "Body", { 2.85, 2.85, 0.5 }, { 1, 1, 0 }, true },
			{ "SpEdgeD", "Body", { 2.85, -2.85, 0.5 }, { 1, -1, 0 }, true },
			{ "SpEdgeB", "Body", { 2.85, 0.4, 2.85 }, { 1, 0, 1 }, true },
			{ "SpBack", "Body", { 0, 2.85, 2.85 }, { 0, 1, 1 }, false },
			{ "SpChin", "Body", { 0, -2.85, -2.85 }, { 0, -1, -1 }, false },
			{ "SpSideA", "Side", { 3.8, 1.9, 0.7 }, { 1, 0.3, 0 }, true },
			{ "SpSideB", "Side", { 3.8, -1.7, 0.5 }, { 1, -0.3, 0 }, true },
			{ "SpSideC", "Side", { 3.8, 0.1, 1.9 }, { 1, 0, 0.35 }, true },
			{ "SpRearU", "Rear", { 1.7, 1.6, 3.8 }, { 0.3, 0.3, 1 }, true },
			{ "SpRearD", "Rear", { 1.7, -1.6, 3.8 }, { 0.3, -0.3, 1 }, true },
			{ "SpBellyA", "Belly", { 1.5, -3.8, -0.8 }, { 0.3, -1, -0.2 }, true },
			{ "SpBellyB", "Belly", { 0, -3.8, 1.3 }, { 0, -1, 0.3 }, false },
		}
		local GLOWTIP = { SpTopA = true, SpTopB = true, SpBack = true, SpEdgeU = true }
		local function spine(name, parent, p, d, key)
			local base = rp(p[1], p[2], p[3])
			local dir = v(d[1], d[2], d[3]).Unit
			local b = B:bone(name, parent, base)
			B:beam(b, base - dir * 1.0, base + dir * 0.55, 0.7, 0.7, GOLD)
			if GLOWTIP[key] then
				B:beam(b, base + dir * 0.5, base + dir * 1.0, 0.4, 0.4, NGOLD, NEON)
			else
				B:beam(b, base + dir * 0.5, base + dir * 1.0, 0.4, 0.4, "#ffe9a6")
			end
		end
		for _, s in SPINES do
			if s[5] then
				B:sym(function(side)
					local parent = s[2] == "Side" and ("Side" .. side) or s[2]
					spine(s[1] .. side, parent, s[3], s[4], s[1])
				end)
			else
				spine(s[1], s[2], s[3], s[4], s[1])
			end
		end

		------------------------------------------------------------------
		-- personality extras: "!" startle mark, sweat drop
		------------------------------------------------------------------
		local alert = B:bone("Alert", "Body", rp(3.4, 5.0, -1.0))
		local a1 = B:block(alert, v(0.6, 1.4, 0.6), at(3.4, 5.6, -1.0), NGOLD, { mat = "Neon", tr = 1, name = "Alert1" })
		B:block(alert, v(0.6, 0.6, 0.6), at(3.4, 4.4, -1.0), NGOLD, { mat = "Neon", tr = 1, name = "Alert2" })
		B:emitter(a1, "burst", { name = "StartleBurst", color = { "#ffffff", NGOLD }, speed = { 6, 12 }, size = { 0.7, 0.4, 0 } })
		local sweat = B:bone("Sweat", "Body", rp(-3.4, 2.6, -2.4))
		B:block(sweat, v(0.55, 0.7, 0.4), at(-3.4, 2.6, -2.4), SWEAT, { tr = 1, name = "SweatA" })
		B:block(sweat, v(0.35, 0.35, 0.35), at(-3.4, 3.1, -2.4, 0, 0, 45), SWEAT, { tr = 1, name = "SweatB" })

		------------------------------------------------------------------
		-- floating marble cubes (gold band + tiny turquoise rune dot)
		------------------------------------------------------------------
		local CUBES = { { 7.2, 10.0, -2.5, 1.4 }, { -7.4, 8.0, -1.0, 1.2 }, { 6.4, 4.2, 4.0, 1.0 }, { -5.8, 11.6, 3.6, 1.1 } }
		for i, o in CUBES do
			local cb2 = B:bone("Cube" .. i, "Root", v(o[1], o[2], o[3]))
			local s = o[4]
			B:block(cb2, v(s, s, s), cf(o[1], o[2], o[3]), MARBLE)
			B:block(cb2, v(s + 0.1, s * 0.25, s + 0.1), cf(o[1], o[2] + s * 0.2, o[3]), GOLD)
			B:block(cb2, v(0.3, 0.3, 0.1), cf(o[1], o[2] - s * 0.15, o[3] - s / 2 - 0.03), TURQ, NEON)
		end

		------------------------------------------------------------------
		-- voxel bubbles (hidden) for idle burps and the "pfft"
		------------------------------------------------------------------
		local BC = rp(0, -1.3, -4.6)
		for k = 1, 5 do
			local bb = B:bone("Bub" .. k, "Root", BC)
			local s = (k % 2 == 1) and 0.7 or 0.5
			B:block(bb, v(s, s, s), CFrame.new(BC), BUBC, { tr = 1, name = "BubP" .. k })
		end
	end,
}
