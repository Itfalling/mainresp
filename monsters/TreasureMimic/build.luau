--!nocheck
-- Treasure Mimic: a greedy stud-built treasure chest that bites back.
-- Color-blocked wood planks, gold lip / bands / corner brackets / claw feet,
-- angry cartoon eyes on the lid, zipper rows of white block teeth, a lolling
-- magenta tongue, a gold coin hoard in the mouth, a dangling padlock and a
-- tilted crown. VFX: orbiting gold voxel coins, loot coins that spray out of
-- the mouth on the signature "Greedy Chomp", gold sparkles, coin bursts, dust.
return {
	DisplayName = "Treasure Mimic",
	Rarity = "Epic",
	Element = "Greed",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang

		-- palette ----------------------------------------------------------
		local MAIN, DARK, DEEP = "#8a5a2b", "#6b4220", "#3a2312" -- wood, dark wood, brows/lashes
		local GOLD, GOLDD = "#f2c230", "#c98f1a" -- gold trim + its shade
		local WHITE, MOUTH = "#fbf6ea", "#170c10" -- teeth/claws, mouth
		local TONGUE, TONGUED = "#c2406b", "#93264d"
		local EYE, NEON = "#ffd23a", "#fff1a6" -- yellow eyes, the ONE neon accent
		local RUBY, SAPH, EMER = "#e8304a", "#2f7dff", "#2fcf6a"

		-- dimensions (studs) -------------------------------------------------
		local W, D = 9, 7 -- chest width (X) and depth (Z)
		local HW, HD = W / 2, D / 2
		local BOT = 2.0 -- underside of the box
		local RIM = 5.5 -- top of the box rim = lid hinge height
		local TX = -2.0 -- tongue lolls out of the left side of the mouth
		local WT = 0.8 -- rim wall thickness

		-- stepped voxel tooth: wide root block + narrower tip block
		local function tooth(bone, x, y, z, big, down)
			local b = big and v(1.1, 0.8, 0.8) or v(0.9, 0.6, 0.6)
			local t = big and v(0.55, 0.8, 0.6) or v(0.45, 0.5, 0.45)
			local sgn = down and -1 or 1
			local by = y + sgn * (b.Y / 2 - 0.12)
			B:block(bone, b, cf(x, by, z), WHITE)
			B:block(bone, t, cf(x, by + sgn * (b.Y / 2 + t.Y / 2 - 0.05), z), WHITE)
		end

		------------------------------------------------------------------
		-- BODY (the box = lower jaw)
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, BOT, 0))
		-- color-blocked planks
		B:block(body, v(W, 1, D), cf(0, 2.5, 0), MAIN)
		B:block(body, v(W, 1, D), cf(0, 3.5, 0), DARK)
		B:block(body, v(W, 1, D), cf(0, 4.5, 0), MAIN)
		-- dark rim walls (the lower lip) with a gap where the tongue flops out
		local rimY = (5.0 + RIM) / 2
		local rimH = RIM - 5.0
		local nR, nL = TX + 0.8, TX - 0.8 -- notch edges
		B:block(body, v(HW - nR, rimH, WT), cf((HW + nR) / 2, rimY, -HD + WT / 2), DARK)
		B:block(body, v(nL + HW, rimH, WT), cf((nL - HW) / 2, rimY, -HD + WT / 2), DARK)
		B:block(body, v(W, rimH, WT), cf(0, rimY, HD - WT / 2), DARK)
		B:sym(function()
			B:block(body, v(WT, rimH, D - 2 * WT + 0.02), cf(HW - WT / 2, rimY, 0), DARK)
		end)
		B:block(body, v(W - 2 * WT + 0.1, 0.3, D - 2 * WT + 0.1), cf(0, 5.05, 0), MOUTH) -- mouth floor
		-- gold corner brackets + side straps
		B:sym(function()
			for _, z in { -HD, HD } do
				B:block(body, v(0.8, RIM - BOT + 0.1, 0.8), cf(HW - 0.3, (BOT + RIM) / 2, z + (z < 0 and 0.3 or -0.3)), GOLD)
			end
			B:block(body, v(0.2, 3.0, 1.0), cf(HW + 0.05, 3.5, 0), GOLDD)
		end)
		-- chest handles (swing on their own bones)
		B:sym(function(side)
			for _, z in { -0.75, 0.75 } do
				B:block(body, v(0.5, 0.5, 0.4), cf(HW + 0.3, 4.45, z), GOLDD)
			end
			local hb = B:bone("Handle" .. side, "Body", v(HW + 0.45, 4.45, 0))
			B:block(hb, v(0.3, 1.2, 0.3), cf(HW + 0.45, 3.95, -0.75), GOLD)
			B:block(hb, v(0.3, 1.2, 0.3), cf(HW + 0.45, 3.95, 0.75), GOLD)
			B:block(hb, v(0.3, 0.3, 1.8), cf(HW + 0.45, 3.35, 0), GOLD)
		end)
		-- padlock staple on the front + back hinges
		B:block(body, v(0.9, 0.6, 0.5), cf(0, 4.6, -HD - 0.15), GOLDD)
		B:sym(function()
			B:block(body, v(1.4, 0.8, 0.4), cf(2.6, RIM - 0.4, HD + 0.12), GOLDD)
		end)
		-- lower teeth (point up out of the rim), interleaved with the lid's
		for _, x in { 0, 1.6, 3.2, -3.4 } do
			tooth(body, x, RIM, -HD + 0.4, false, false)
		end
		B:sym(function()
			tooth(body, HW - 0.4, RIM, -0.6, false, false)
		end)

		-- gold hoard inside the mouth (jiggles on its own bone)
		local pile = B:bone("CoinPile", "Body", v(0, 5.1, 0))
		B:block(pile, v(4.9, 0.5, 4.2), cf(1.15, 5.3, 0.5), GOLDD)
		B:block(pile, v(3.6, 0.5, 3.0), cf(1.3, 5.6, 0.7), GOLD)
		B:block(pile, v(2.0, 0.4, 1.6), cf(1.5, 5.85, 0.3), GOLD)
		B:block(pile, v(1.2, 0.3, 1.2), cf(-3.0, 5.3, 1.6, 0, 25, 14), GOLD)
		B:block(pile, v(1.2, 0.3, 1.2), cf(3.0, 5.7, 1.6, 10, 40, -18), GOLD)
		B:block(pile, v(0.8, 0.8, 0.8), cf(2.9, 5.7, -0.9, 30, 45, 0), RUBY)
		B:block(pile, v(0.8, 0.8, 0.8), cf(-0.6, 5.5, 1.6, 0, 45, 30), SAPH)
		B:block(pile, v(0.7, 0.7, 0.7), cf(-3.1, 5.45, -0.4, 45, 0, 30), EMER)

		-- loot coins: rest on the hoard, spray out of the mouth during the chomp
		local lootAt = { { 0.6, 5.95, 0.1 }, { 2.3, 5.95, 0.9 }, { -0.4, 5.75, 0.6 }, { 1.8, 6.1, -0.5 } }
		for i, p in lootAt do
			local lb = B:bone("Loot" .. i, "Body", v(p[1], p[2], p[3]))
			local c0 = cf(p[1], p[2], p[3]) * ang(70 + i * 9, i * 40, 0)
			B:block(lb, v(1.3, 1.3, 0.35), c0, GOLD)
			B:block(lb, v(0.7, 0.7, 0.45), c0, GOLDD)
			B:trail(lb, v(p[1] - 0.5, p[2], p[3]), v(p[1] + 0.5, p[2], p[3]), { name = "LootTrail" .. i, color = { "#fff3b0", GOLD }, life = 0.22, trans = { 0.35, 1 } })
		end

		-- effect emitters on the body
		local aura = B:block(body, v(8, 5, 6), cf(0, 6.5, 0), GOLD, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "sparkle", { name = "GoldSparkle", color = { "#fff6c8", GOLD }, rate = 5 })
		local mouthFx = B:block(body, v(5, 0.6, 3.5), cf(0, 6.0, -0.3), GOLD, { tr = 1, name = "MouthFX" })
		B:emitter(mouthFx, "burst", { name = "CoinBurst", color = { "#fff6c8", GOLD, "#ffb21a" }, size = { 1.1, 0.8, 0 }, speed = { 10, 18 }, spread = 55 })
		B:emitter(mouthFx, "sparkle", { name = "MouthSparkle", color = { "#ffffff", GOLD }, rate = 10, enabled = false })
		B:light(mouthFx, { name = "MouthLight", color = "#ffc94a", brightness = 0.5, range = 11 })
		local chompFx = B:block(body, v(5, 0.6, 0.6), cf(0, RIM, -HD - 0.3), GOLD, { tr = 1, name = "ChompFX" })
		B:emitter(chompFx, "spark", { name = "ChompSparks", color = { "#ffffff", GOLD }, enabled = false })

		------------------------------------------------------------------
		-- LID (upper jaw / head) hinged at the back top edge
		------------------------------------------------------------------
		local L2B, L2T = RIM + 0.5, RIM + 3.0 -- eye band
		local lid = B:bone("Lid", "Body", v(0, RIM, HD))
		B:block(lid, v(W + 0.2, 0.5, D + 0.2), cf(0, RIM + 0.25, 0), GOLD) -- gold upper lip
		B:block(lid, v(W, L2T - L2B, D), cf(0, (L2B + L2T) / 2, 0), MAIN)
		B:block(lid, v(W, 1.0, 5.0), cf(0, L2T + 0.5, 0), DARK)
		B:block(lid, v(W, 0.5, 2.6), cf(0, L2T + 1.25, 0), MAIN)
		B:block(lid, v(W - 1.6, 0.3, D - 1.6), cf(0, RIM - 0.05, 0), MOUTH) -- roof of the mouth
		for i, z in { -1.6, 0.0, 1.6 } do
			B:block(lid, v(5.6 - i * 0.8, 0.12, 0.6), cf(0, RIM - 0.24, z), "#5c1a33") -- palate ridges
		end
		-- gold bands over the stepped arch
		-- gold corner brackets (continue the box's) + end caps over the arch
		B:sym(function()
			local bx = HW - 0.3
			for _, z in { -HD, HD } do
				B:block(lid, v(0.8, L2T - L2B + 0.1, 0.8), cf(bx, (L2B + L2T) / 2, z + (z < 0 and 0.3 or -0.3)), GOLD)
			end
			B:block(lid, v(0.2, L2T - L2B, 1.0), cf(HW + 0.05, (L2B + L2T) / 2, 0), GOLDD)
			B:block(lid, v(0.8, 1.1, 5.15), cf(bx, L2T + 0.5, 0), GOLD)
			B:block(lid, v(0.8, 0.6, 2.75), cf(bx, L2T + 1.25, 0), GOLD)
		end)
		-- hasp tab + back hinges
		B:sym(function()
			B:block(lid, v(1.4, 0.8, 0.4), cf(2.6, RIM + 0.4, HD + 0.12), GOLDD)
		end)
		-- upper teeth (hang down), leaving a gap where the tongue lolls out
		for _, x in { 0.8, 2.4, -0.8 } do
			tooth(lid, x, RIM, -HD + 0.4, false, true)
		end
		B:sym(function()
			tooth(lid, HW - 0.65, RIM, -HD + 0.45, true, true) -- corner fangs
			for _, z in { 0.6, 2.4 } do
				tooth(lid, HW - 0.4, RIM, z, false, true)
			end
		end)

		-- cartoon eyes: dark socket, yellow eye, small neon core, pupil on a bone
		local EY, EX = (L2B + L2T) / 2, 2.05
		B:sym(function(side)
			B:block(lid, v(2.8, 2.4, 0.2), cf(EX, EY, -HD - 0.05), DEEP)
			B:block(lid, v(2.4, 2.0, 0.2), cf(EX, EY, -HD - 0.15), EYE)
			B:block(lid, v(1.2, 1.2, 0.1), cf(EX - 0.05, EY - 0.05, -HD - 0.27), NEON, { mat = "Neon", name = "EyeCore" })
			local pupil = B:bone("Pupil" .. side, "Lid", v(EX, EY, -HD - 0.3))
			B:block(pupil, v(0.6, 1.3, 0.15), cf(EX - 0.05, EY - 0.05, -HD - 0.36), MOUTH)
			B:block(pupil, v(0.3, 0.3, 0.1), cf(EX - 0.15, EY + 0.35, -HD - 0.46), "#ffffff")
			-- eyelid hides inside the lid, pops out to blink
			local eyelid = B:bone("Eyelid" .. side, "Lid", v(EX, EY, -HD + 0.6))
			B:block(eyelid, v(2.8, 2.4, 0.4), cf(EX, EY, -HD + 0.4), MAIN)
			B:block(eyelid, v(2.8, 0.35, 0.5), cf(EX, EY - 1.05, -HD + 0.4), DEEP)
			-- heavy angry brow (inner end low)
			local brow = B:bone("Brow" .. side, "Lid", v(EX, L2T + 0.15, -HD + 0.3))
			B:block(brow, v(3.0, 0.8, 1.4), cf(EX, L2T + 0.15, -HD + 0.3, 0, 0, 16), DEEP)
		end)

		-- tilted crown (bounces off during the jump)
		local CP = v(0.9, L2T + 1.5, 0.1)
		local crown = B:bone("Crown", "Lid", CP)
		local CC = CFrame.new(CP) * ang(0, 18, -12)
		B:block(crown, v(2.8, 0.8, 2.4), CC * CFrame.new(0, 0.4, 0), GOLD)
		B:block(crown, v(2.9, 0.3, 2.5), CC * CFrame.new(0, 0.05, 0), GOLDD)
		local prongs = { { -1.1, -0.9, 0.6 }, { 1.1, -0.9, 0.6 }, { -1.1, 0.9, 0.6 }, { 1.1, 0.9, 0.6 }, { 0, -0.9, 1.0 }, { 0, 0.9, 1.0 } }
		for _, pr in prongs do
			local h = pr[3]
			B:block(crown, v(0.6, h, 0.6), CC * CFrame.new(pr[1], 0.8 + h / 2, pr[2]), GOLD)
			B:block(crown, v(0.4, 0.4, 0.4), CC * CFrame.new(pr[1], 0.8 + h + 0.15, pr[2]), NEON, { mat = "Neon" })
		end
		B:block(crown, v(0.8, 0.5, 0.2), CC * CFrame.new(0, 0.4, -1.25), RUBY)
		B:trail(crown, CP + v(-1, 1.3, 0), CP + v(1, 1.3, 0), { name = "CrownTrail", color = { "#fff3b0", GOLD }, life = 0.2, trans = { 0.5, 1 } })

		------------------------------------------------------------------
		-- PADLOCK dangling from the staple
		------------------------------------------------------------------
		local LP = v(0, 4.6, -HD - 0.45)
		local lock = B:bone("Lock", "Body", LP)
		B:block(lock, v(0.3, 0.9, 0.3), cf(-0.45, 4.25, LP.Z), GOLDD)
		B:block(lock, v(0.3, 0.9, 0.3), cf(0.45, 4.25, LP.Z), GOLDD)
		B:block(lock, v(1.2, 0.3, 0.3), cf(0, 4.7, LP.Z), GOLDD)
		B:block(lock, v(1.6, 1.4, 0.7), cf(0, 3.2, LP.Z), GOLD)
		B:block(lock, v(1.2, 0.3, 0.8), cf(0, 2.6, LP.Z), GOLDD)
		B:block(lock, v(0.3, 0.6, 0.1), cf(0, 3.25, LP.Z - 0.38), MOUTH)

		------------------------------------------------------------------
		-- TONGUE (5-bone chain): lies on the hoard, flops over the rim gap,
		-- hangs down the front of the box
		------------------------------------------------------------------
		local TZ = -HD - 0.35
		local TY = RIM - 0.25
		local tsegs = {
			-- pivot, size, center, horizontal?
			{ v(TX, TY, 1.4), v(1.4, 0.5, 2.8), v(TX, TY, 0.0), true },
			{ v(TX, TY, -1.3), v(1.4, 0.5, 2.85), v(TX, TY, -2.675), true },
			{ v(TX, TY, TZ), v(1.4, 1.5, 0.5), v(TX, TY - 0.65, TZ), false },
			{ v(TX, TY - 1.3, TZ), v(1.4, 1.4, 0.5), v(TX, TY - 1.95, TZ), false },
			{ v(TX, TY - 2.55, TZ), v(1.4, 0.9, 0.5), v(TX, TY - 2.95, TZ), false },
		}
		local parent = "Body"
		for i, s in tsegs do
			local tb = B:bone("Tongue" .. i, parent, s[1])
			B:block(tb, s[2], CFrame.new(s[3]), TONGUE)
			local g = s[4] and v(0.3, s[2].Y + 0.06, s[2].Z - 0.2) or v(0.3, s[2].Y - 0.2, s[2].Z + 0.06)
			B:block(tb, g, CFrame.new(s[3]), TONGUED)
			parent = "Tongue" .. i
		end
		B:block("Tongue5", v(0.8, 0.5, 0.5), cf(TX, TY - 3.6, TZ), TONGUE)
		B:trail("Tongue5", v(TX - 0.6, TY - 3.3, TZ), v(TX + 0.6, TY - 3.3, TZ), { name = "TongueTrail", color = { "#ff7fae", TONGUE }, life = 0.25, trans = { 0.4, 1 } })

		------------------------------------------------------------------
		-- LEGS: stubby dark-wood legs on gold lion-claw feet
		------------------------------------------------------------------
		B:sym(function(side)
			for _, fz in { { "F", -2.0 }, { "B", 2.0 } } do
				local tag, z = fz[1], fz[2]
				local leg = B:bone("Leg" .. tag .. side, "Body", v(3.0, 2.2, z))
				B:block(leg, v(1.4, 1.4, 1.4), cf(3.0, 1.75, z), DARK)
				local foot = B:bone("Foot" .. tag .. side, "Leg" .. tag .. side, v(3.0, 1.0, z))
				B:block(foot, v(2.0, 0.6, 2.4), cf(3.0, 0.3, z - 0.2), GOLD)
				B:block(foot, v(1.6, 0.5, 1.8), cf(3.0, 0.8, z - 0.05), GOLDD)
				for k = -1, 1 do
					B:wedge(foot, v(0.5, 0.6, 0.9), cf(3.0 + k * 0.7, 0.3, z - 1.75), WHITE)
				end
			end
		end)

		-- landing dust at the feet
		local ground = B:block("Root", v(9, 0.2, 7), cf(0, 0.1, 0), DARK, { tr = 1, name = "GroundFX" })
		B:emitter(ground, "dust", { name = "LandDust", color = "#e3d2b0" })

		-- hidden 3D sparkle stars that flash "ting!" on the gold trim
		local function glint(name, parentBone, pos)
			local gb = B:bone(name, parentBone, pos)
			B:block(gb, v(0.22, 1.8, 0.22), CFrame.new(pos), "#fffbe0", { mat = "Neon", tr = 1, name = name .. "a" })
			B:block(gb, v(1.8, 0.22, 0.22), CFrame.new(pos), "#fffbe0", { mat = "Neon", tr = 1, name = name .. "b" })
			B:block(gb, v(0.22, 0.22, 1.4), CFrame.new(pos), "#fffbe0", { mat = "Neon", tr = 1, name = name .. "c" })
		end
		glint("Glint1", "Lid", v(HW + 0.2, L2T + 0.2, -HD - 0.2))
		glint("Glint2", "Body", v(-HW - 0.2, 2.6, -HD - 0.2))

		------------------------------------------------------------------
		-- ORBITING GOLD VOXEL COINS + GEM CUBES
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 6, 0))
		local R = 6.4
		local hs = { 6.5, 3.5, 8.5, 4.5, 7.5 }
		for i = 1, 5 do
			local a = math.rad((i - 1) * 72 + 20)
			local p = v(R * math.cos(a), hs[i], R * math.sin(a))
			local ob = B:bone("Coin" .. i, "Orbit", p)
			if i == 2 or i == 4 then
				local col = i == 2 and RUBY or SAPH
				B:block(ob, v(1.1, 1.1, 1.1), CFrame.new(p) * ang(45, 45, 0), col)
				B:block(ob, v(0.35, 0.35, 0.35), CFrame.new(p) * ang(45, 45, 0) * CFrame.new(0.4, 0.4, -0.4), "#ffffff")
			else
				B:block(ob, v(1.5, 1.5, 0.4), CFrame.new(p), GOLD)
				B:block(ob, v(0.8, 0.8, 0.5), CFrame.new(p), GOLDD)
			end
		end
	end,
}
