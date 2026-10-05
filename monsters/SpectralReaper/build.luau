--!nocheck
-- Spectral Reaper: floating stud-built hooded wraith. Indigo robe with
-- stepped tattered hem strips, a grinning black hood with glowing mint eyes,
-- bone-white horns/hands/ribs, a big voxel scythe and a soul lantern.
-- Glow is kept to small mint accents (eyes, blade edge, tips, lantern core).
return {
	DisplayName = "Spectral Reaper",
	Rarity = "Secret",
	Element = "Spirit",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local ROBE, SHADE, DARK, TRIM = "#3d3290", "#2b2862", "#1c1b2b", "#5548b8"
		local BONE, BONE_D, BLACK, MINT = "#e8e4d8", "#bdb5a0", "#0c0b12", "#5dffd6"
		local BLADE, BLADE_D, HANDLE, CHAIN = "#d8d5ee", "#9b97c2", "#352a3d", "#6d6a8c"
		local NEON = { mat = "Neon" }

		------------------------------------------------------------------
		-- Body: stepped robe skirt (floats, no legs)
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 8.5, 0))
		-- dark inner core so gaps between hem strips read as robe, not legs
		B:block(body, v(5.4, 2.2, 3.8), cf(0, 5.0, 0.1), DARK)
		-- tier A (hips): short, the flame strips hang from it
		B:block(body, v(6.6, 1.6, 5.2), cf(0, 6.3, 0.1), ROBE)
		B:block(body, v(6.7, 0.35, 5.3), cf(0, 7.05, 0.1), TRIM)
		-- tier B (waist)
		B:block(body, v(6.4, 2.4, 5.0), cf(0, 8.25, 0.1), ROBE)
		B:sym(function()
			B:block(body, v(0.3, 2.0, 3.4), cf(3.25, 8.2, 0.1), SHADE)
		end)
		-- front robe opening (dark panels, stepped)
		B:block(body, v(1.8, 1.4, 0.3), cf(0, 6.3, -2.55), DARK)
		B:block(body, v(1.5, 2.4, 0.3), cf(0, 8.25, -2.45), DARK)
		-- chain belt with a little skull buckle
		B:block(body, v(6.6, 0.7, 5.15), cf(0, 9.45, 0.1), CHAIN)
		B:block(body, v(1.3, 1.1, 0.4), cf(0, 9.45, -2.6), BONE)
		B:sym(function()
			B:block(body, v(0.32, 0.32, 0.1), cf(0.28, 9.57, -2.83), BLACK)
		end)

		-- ghostly mist + sparkles around the robe
		local mist = B:block(body, v(6, 1, 4.5), cf(0, 3.0, 0.1), DARK, { tr = 1, name = "MistVolume" })
		B:emitter(mist, "smoke", { name = "Wisps", color = { "#9effe6", "#3a3660" }, rate = 5, size = { 1.0, 2.6, 3.6 }, accel = { 0, -0.4, 0 }, speed = { 0.3, 0.9 } })
		B:emitter(mist, "dust", { name = "LandDust", color = { "#cfc8ff", "#5dffd6" } })
		B:emitter(mist, "smoke", { name = "SpinMist", color = { "#9effe6", "#5548b8" }, rate = 22, enabled = false, speed = { 3, 7 }, spread = 180, size = { 1.2, 2.8, 4 }, life = { 0.6, 1.2 } })
		local aura = B:block(body, v(8, 9, 6), cf(0, 10, 0), DARK, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "sparkle", { name = "Sparkles", color = { "#ffffff", MINT }, rate = 3 })

		------------------------------------------------------------------
		-- Tattered hem strips (2-bone chains around the skirt, ripple like flames)
		------------------------------------------------------------------
		-- {x, z, dirX, dirZ, width, length "L"/"M"/"S"}  (front, right, back, left)
		local hems = {
			{ -2.4, -2.35, 0, -1, 1.8, "L" },
			{ -0.8, -2.35, 0, -1, 1.8, "S" },
			{ 0.8, -2.35, 0, -1, 1.8, "M" },
			{ 2.4, -2.35, 0, -1, 1.8, "L" },
			{ 3.15, -1.55, 1, 0, 1.75, "S" },
			{ 3.15, 0.1, 1, 0, 1.75, "L" },
			{ 3.15, 1.75, 1, 0, 1.75, "M" },
			{ 2.4, 2.55, 0, 1, 1.8, "L" },
			{ 0.8, 2.55, 0, 1, 1.8, "S" },
			{ -0.8, 2.55, 0, 1, 1.8, "M" },
			{ -2.4, 2.55, 0, 1, 1.8, "L" },
			{ -3.15, 1.75, -1, 0, 1.75, "M" },
			{ -3.15, 0.1, -1, 0, 1.75, "L" },
			{ -3.15, -1.55, -1, 0, 1.75, "S" },
		}
		for i, h in hems do
			local pos = v(h[1], 6.4, h[2])
			local dir = v(h[3], 0, h[4])
			local frame = CFrame.lookAt(pos, pos + dir) -- local -Z points outward
			local function at(lx, ly, lz)
				return frame * CFrame.new(lx, ly, lz)
			end
			local w, len = h[5], h[6]
			-- alternate light/dark strips; the two front-centre strips continue the robe opening
			local top, mid, tip = ROBE, ROBE, SHADE
			if i % 2 == 0 then
				mid, tip = SHADE, DARK
			end
			if i == 2 or i == 3 then
				top, mid, tip = SHADE, DARK, DARK
			end
			local a = B:bone("HemA" .. i, "Body", frame)
			B:block(a, v(w, 2.4, 0.7), at(0, -0.55, 0), top)
			local b = B:bone("HemB" .. i, "HemA" .. i, at(0, -1.6, 0))
			if len == "L" then
				B:block(b, v(w - 0.5, 1.6, 0.6), at(0, -2.5, 0), mid)
				B:block(b, v(w - 1.0, 1.0, 0.55), at(0, -3.7, 0), tip)
				B:block(b, v(0.4, 0.4, 0.4), at(0, -4.35, -0.02), MINT, NEON)
				if i == 1 or i == 4 or i == 8 or i == 11 then
					-- ghostly ribbons streaming off the longest tatters
					B:trail(b, at(0, -3.4, 0).Position, at(0, -4.3, 0).Position, { name = "HemTrail" .. i, color = { MINT, "#5548b8" }, life = 0.45, trans = { 0.55, 1 } })
				end
			elseif len == "M" then
				B:block(b, v(w - 0.5, 1.3, 0.6), at(0, -2.35, 0), mid)
				B:block(b, v(w - 1.0, 0.8, 0.55), at(0, -3.35, 0), tip)
			else
				B:block(b, v(w - 0.6, 1.0, 0.6), at(0, -2.2, 0), mid)
				B:block(b, v(0.6, 0.6, 0.55), at(0, -2.95, 0), tip)
			end
		end

		------------------------------------------------------------------
		-- Hanging belt chain (secondary motion)
		------------------------------------------------------------------
		local chA = B:bone("ChainA", "Body", v(2.2, 9.2, -2.95))
		B:block(chA, v(0.2, 0.75, 0.5), cf(2.2, 8.75, -3.0), CHAIN)
		B:block(chA, v(0.5, 0.75, 0.2), cf(2.2, 8.15, -3.0), CHAIN)
		local chB = B:bone("ChainB", "ChainA", v(2.2, 7.8, -3.0))
		B:block(chB, v(0.2, 0.75, 0.5), cf(2.2, 7.5, -3.0), CHAIN)
		B:block(chB, v(0.8, 0.8, 0.8), cf(2.2, 6.8, -3.1), BONE)
		B:block(chB, v(0.22, 0.22, 0.1), cf(2.02, 6.88, -3.53), BLACK)
		B:block(chB, v(0.22, 0.22, 0.1), cf(2.38, 6.88, -3.53), BLACK)

		------------------------------------------------------------------
		-- Chest: robe torso, ribcage peeking out, mantle, cape
		------------------------------------------------------------------
		local chest = B:bone("Chest", "Body", v(0, 9.5, 0.3))
		B:block(chest, v(6.0, 3.4, 4.6), cf(0, 11.0, 0.2), ROBE)
		-- ribcage opening
		B:block(chest, v(2.9, 2.8, 0.3), cf(0, 11.1, -2.15), BLACK)
		for i, w in { 2.5, 2.1, 1.6 } do
			B:block(chest, v(w, 0.36, 0.3), cf(0, 11.95 - (i - 1) * 0.68, -2.36), BONE)
		end
		B:block(chest, v(0.45, 2.3, 0.34), cf(0, 11.25, -2.38), BONE)
		local soul = B:bone("Soul", "Chest", v(-0.7, 11.3, -2.2))
		B:block(soul, v(0.7, 0.7, 0.2), cf(-0.7, 11.27, -2.31), MINT, { mat = "Neon", name = "SoulGem" })
		-- mantle (open at the front so the ribs show)
		B:sym(function()
			B:block(chest, v(2.8, 1.3, 5.4), cf(2.4, 12.65, 0.35), ROBE)
			B:block(chest, v(2.9, 0.35, 5.5), cf(2.4, 12.0, 0.35), TRIM)
			B:block(chest, v(0.9, 0.8, 0.4), cf(1.45, 11.6, -2.3), TRIM)
			B:block(chest, v(0.3, 2.4, 3.6), cf(3.05, 10.8, 0.2), SHADE)
		end)
		B:block(chest, v(2.2, 1.3, 2.6), cf(0, 12.65, 1.75), ROBE)
		local burstAt = B:block(chest, v(2, 2, 1), cf(0, 11, -2.6), DARK, { tr = 1, name = "SoulFX" })
		B:emitter(burstAt, "burst", { name = "SoulBurst", color = { "#ffffff", MINT }, size = { 1.1, 0.7, 0 } })
		B:light(burstAt, { name = "SoulLight", color = MINT, brightness = 0, range = 16 })

		-- tattered two-piece cape on the back with stepped bone spine plates
		local function plate(bone, y, z)
			B:block(bone, v(1.0, 1.0, 0.8), cf(0, y, z + 0.5), BONE)
			B:block(bone, v(0.7, 0.7, 0.7), cf(0, y + 0.1, z + 1.15), BONE)
			B:block(bone, v(0.42, 0.42, 0.42), cf(0, y + 0.15, z + 1.65), MINT, NEON)
		end
		local cape = B:bone("Cape", "Chest", v(0, 12.6, 2.9))
		B:block(cape, v(6.4, 3.8, 0.4), cf(0, 10.8, 3.1), ROBE)
		B:block(cape, v(6.5, 0.35, 0.5), cf(0, 12.6, 3.1), TRIM)
		B:block(cape, v(2.0, 3.6, 0.15), cf(0, 10.8, 3.35), SHADE)
		plate(cape, 11.7, 3.1)
		plate(cape, 10.0, 3.1)
		local cape2 = B:bone("Cape2", "Cape", v(0, 9.0, 3.1))
		B:block(cape2, v(5.8, 1.8, 0.4), cf(0, 8.2, 3.15), ROBE)
		B:block(cape2, v(2.0, 1.8, 0.15), cf(0, 8.2, 3.4), SHADE)
		for _, x in { -2.1, 0, 2.1 } do
			B:block(cape2, v(1.3, 1.1, 0.4), cf(x, 6.9, 3.15), SHADE)
		end

		------------------------------------------------------------------
		-- Head: big stepped hood, black face, glowing eyes, toothy grin, horns
		------------------------------------------------------------------
		local head = B:bone("Head", "Chest", v(0, 12.8, 0.4))
		B:block(head, v(6.6, 2.0, 5.6), cf(0, 13.8, 0.8), ROBE)
		B:block(head, v(6.4, 2.6, 5.2), cf(0, 16.1, 0.8), ROBE)
		B:block(head, v(5.2, 1.2, 4.6), cf(0, 18.0, 1.0), ROBE)
		B:block(head, v(3.6, 1.0, 3.6), cf(0, 19.1, 1.4), ROBE)
		B:block(head, v(3.7, 0.3, 3.7), cf(0, 18.65, 1.4), TRIM)
		-- pointed hood tip, curling backward
		B:block(head, v(2.2, 1.2, 2.4), cf(0, 20.15, 1.9), ROBE)
		B:block(head, v(1.4, 1.0, 1.8), cf(0, 20.55, 3.5), SHADE)
		B:block(head, v(0.9, 0.8, 1.3), cf(0, 20.1, 4.9), DARK)
		B:gem(head, v(0.42, 0.42, 0.42), cf(0, 19.6, 5.45), MINT)
		B:block(head, v(6.7, 0.35, 5.7), cf(0, 12.95, 0.8), TRIM)
		B:block(head, v(3.0, 2.4, 0.3), cf(0, 16.1, 3.5), SHADE)
		-- darker side panels on the hood
		B:sym(function()
			B:block(head, v(0.3, 3.6, 3.8), cf(3.25, 15.4, 1.3), SHADE)
		end)
		-- rim around the face opening
		B:block(head, v(6.2, 1.2, 1.8), cf(0, 17.9, -2.3), TRIM)
		B:sym(function()
			B:block(head, v(1.0, 4.8, 1.4), cf(2.75, 15.3, -2.2), TRIM)
		end)
		-- thin mint edge under the brim
		B:block(head, v(4.2, 0.2, 0.2), cf(0, 17.25, -3.1), MINT, NEON)
		-- black face
		B:block(head, v(4.6, 4.4, 0.4), cf(0, 15.3, -2.1), BLACK)
		B:sym(function()
			-- eye: mint rectangle + dark pupil + angry brow
			B:block(head, v(1.4, 1.7, 0.2), cf(1.1, 16.25, -2.38), MINT, { mat = "Neon", name = "Eye" })
			B:block(head, v(0.4, 1.0, 0.1), cf(0.95, 16.15, -2.52), BLACK)
			B:block(head, v(2.0, 0.6, 0.6), cf(1.1, 17.3, -2.5, 0, 0, 18), TRIM)
			-- horns: stepped bone voxels curling out and up, mint tips
			B:block(head, v(1.4, 1.3, 1.4), cf(3.55, 17.4, 0.9), BONE)
			B:block(head, v(1.3, 1.1, 1.1), cf(4.6, 17.95, 1.0), BONE)
			B:block(head, v(1.0, 1.2, 0.95), cf(5.2, 18.95, 1.1), BONE)
			B:block(head, v(0.75, 1.0, 0.75), cf(5.3, 19.95, 1.25), BONE)
			B:block(head, v(0.55, 0.55, 0.55), cf(5.3, 20.7, 1.35), MINT, NEON)
		end)
		-- upper teeth
		for _, t in { { -1.6, 1.0 }, { -0.8, 0.62 }, { 0, 0.75 }, { 0.8, 0.62 }, { 1.6, 1.0 } } do
			B:block(head, v(0.6, t[2], 0.3), cf(t[1], 15.2 - t[2] / 2, -2.45), BONE)
		end
		-- mouth glow (only shown while cackling)
		B:block(head, v(3.2, 1.4, 0.1), cf(0, 14.2, -2.35), MINT, { mat = "Neon", tr = 1, name = "MouthGlow" })
		-- eyelids for cartoon blinks
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", v(1.1, 17.4, -2.5))
			B:block(lid, v(1.55, 1.45, 0.25), cf(1.1, 17.7, -2.6), BLACK)
		end)
		-- jaw with lower teeth
		local jaw = B:bone("Jaw", "Head", v(0, 14.4, -1.2))
		B:block(jaw, v(3.8, 0.9, 0.3), cf(0, 13.75, -2.42), BLACK)
		for _, t in { { -1.2, 0.72 }, { -0.4, 0.56 }, { 0.4, 0.56 }, { 1.2, 0.72 } } do
			B:block(jaw, v(0.55, t[2], 0.3), cf(t[1], 14.0 + t[2] / 2, -2.6), BONE)
		end

		------------------------------------------------------------------
		-- Arms: bell sleeves, bony hands. Right holds the scythe, left the lantern
		------------------------------------------------------------------
		B:sym(function(side)
			local arm = B:bone("Arm" .. side, "Chest", v(3.3, 12.1, 0.3))
			B:block(arm, v(2.6, 1.5, 3.2), cf(4.1, 12.9, 0.3), TRIM)
			B:block(arm, v(2.0, 0.5, 2.6), cf(4.1, 13.85, 0.3), SHADE)
			-- stepped bone shoulder spikes
			B:block(arm, v(1.0, 1.0, 1.0), cf(4.5, 14.55, -0.2), BONE)
			B:block(arm, v(0.65, 0.9, 0.65), cf(4.7, 15.4, -0.2), BONE)
			B:block(arm, v(0.75, 0.9, 0.75), cf(4.2, 14.5, 1.1), BONE)
			B:beam(arm, v(4.0, 12.5, 0.3), v(4.8, 9.5, -0.3), 2.1, 2.1, ROBE)
			local fore = B:bone("Fore" .. side, "Arm" .. side, v(4.8, 9.7, -0.3))
			B:beam(fore, v(4.8, 10.0, -0.2), v(5.15, 8.75, -2.3), 2.3, 2.3, ROBE)
			B:beam(fore, v(5.1, 8.85, -2.0), v(5.25, 8.6, -2.75), 3.0, 3.0, TRIM)
			B:beam(fore, v(5.22, 8.6, -2.6), v(5.27, 8.57, -2.85), 2.2, 2.2, BLACK)
			local hand = B:bone("Hand" .. side, "Fore" .. side, v(5.25, 8.55, -2.8))
			B:beam(hand, v(5.25, 8.55, -2.6), v(5.35, 8.45, -3.3), 0.6, 0.6, BONE)
			-- fist wrapped around grip point (5.4, 8.4, -3.7)
			B:block(hand, v(1.3, 1.4, 0.6), cf(5.4, 8.4, -3.2), BONE)
			for k = -1, 1 do
				B:block(hand, v(1.3, 0.4, 0.45), cf(5.4, 8.4 + k * 0.45, -4.15), BONE)
			end
			B:block(hand, v(0.45, 1.4, 1.2), cf(5.95, 8.4, -3.7), BONE_D)
			B:block(hand, v(0.4, 0.4, 0.9), cf(4.95, 8.95, -3.75), BONE)

			local G = v(5.4, 8.4, -3.7)
			if side == "R" then
				--------------------------------------------------------------
				-- Scythe
				--------------------------------------------------------------
				local sc = B:bone("Scythe", "HandR", G)
				B:beam(sc, v(5.4, 3.4, -3.7), v(5.4, 16.6, -3.7), 0.6, 0.6, HANDLE)
				for _, y in { 6.0, 11.4, 14.6 } do
					B:block(sc, v(0.85, 0.4, 0.85), cf(5.4, y, -3.7), BONE)
				end
				B:block(sc, v(0.9, 0.5, 0.9), cf(5.4, 3.4, -3.7), BONE)
				B:block(sc, v(0.5, 0.6, 0.5), cf(5.4, 2.9, -3.7), MINT, NEON)
				-- skull ornament
				B:block(sc, v(1.5, 1.4, 1.4), cf(5.4, 17.3, -3.7), BONE)
				B:block(sc, v(1.1, 0.5, 1.1), cf(5.4, 16.4, -3.75), BONE_D)
				B:block(sc, v(0.4, 0.4, 0.1), cf(5.1, 17.35, -4.44), MINT, NEON)
				B:block(sc, v(0.4, 0.4, 0.1), cf(5.7, 17.35, -4.44), MINT, NEON)
				-- blade: stepped pale crescent with a thin mint cutting edge
				B:block(sc, v(1.2, 1.6, 0.7), cf(6.6, 17.3, -3.7), BLADE_D)
				B:block(sc, v(2.4, 1.8, 0.5), cf(8.2, 17.4, -3.7), BLADE)
				B:block(sc, v(2.0, 1.6, 0.5), cf(10.1, 17.0, -3.7), BLADE)
				B:block(sc, v(1.6, 1.4, 0.5), cf(11.6, 16.2, -3.7), BLADE)
				B:block(sc, v(1.2, 1.2, 0.5), cf(12.5, 15.0, -3.7), BLADE)
				B:block(sc, v(0.8, 1.0, 0.5), cf(12.8, 13.8, -3.7), BLADE)
				B:block(sc, v(4.4, 0.35, 0.6), cf(8.9, 18.25, -3.7), BLADE_D)
				-- little bone spikes along the back of the blade
				for k, x in { 7.6, 9.2, 10.7 } do
					local hgt = k == 2 and 0.9 or 0.7
					B:block(sc, v(0.5, hgt, 0.5), cf(x, 18.4 + hgt / 2 - (k == 3 and 0.35 or 0), -3.7), BONE)
				end
				B:block(sc, v(2.2, 0.22, 0.56), cf(8.2, 16.55, -3.7), MINT, NEON)
				B:block(sc, v(1.8, 0.22, 0.56), cf(10.1, 16.25, -3.7), MINT, NEON)
				B:block(sc, v(0.22, 1.2, 0.56), cf(10.85, 15.6, -3.7), MINT, NEON)
				B:block(sc, v(0.22, 1.1, 0.56), cf(11.95, 14.6, -3.7), MINT, NEON)
				B:block(sc, v(0.22, 0.9, 0.56), cf(12.45, 13.75, -3.7), MINT, NEON)
				B:trail(sc, v(12.8, 13.4, -3.7), v(8.0, 16.6, -3.7), { name = "BladeTrail", color = { "#ffffff", MINT }, life = 0.3, trans = { 0.35, 1 } })
				local edge = B:block(sc, v(5, 2, 0.5), cf(10, 16.5, -3.7), BLADE, { tr = 1, name = "BladeFX" })
				B:emitter(edge, "spark", { name = "BladeSparks", color = { "#ffffff", MINT }, rate = 28, enabled = false })
			else
				--------------------------------------------------------------
				-- Soul lantern (hangs from the left fist)
				--------------------------------------------------------------
				local lan = B:bone("Lantern", "HandL", G)
				B:block(lan, v(0.18, 0.8, 0.5), cf(5.4, 7.55, -3.7), CHAIN)
				B:block(lan, v(0.5, 0.8, 0.18), cf(5.4, 6.9, -3.7), CHAIN)
				B:block(lan, v(0.9, 0.4, 0.9), cf(5.4, 6.4, -3.7), TRIM)
				B:block(lan, v(1.8, 0.45, 1.8), cf(5.4, 6.0, -3.7), SHADE)
				for _, d in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
					B:block(lan, v(0.32, 1.5, 0.32), cf(5.4 + d[1] * 0.7, 5.0, -3.7 + d[2] * 0.7), BONE)
				end
				local core = B:block(lan, v(0.9, 1.2, 0.9), cf(5.4, 5.0, -3.7), MINT, { mat = "Neon", name = "LanternCore" })
				B:block(lan, v(1.8, 0.45, 1.8), cf(5.4, 4.0, -3.7), SHADE)
				B:block(lan, v(0.7, 0.4, 0.7), cf(5.4, 3.6, -3.7), TRIM)
				B:emitter(core, "ember", { name = "LanternMotes", color = { "#ffffff", MINT }, rate = 4, size = { 0.25, 0.15, 0 } })
				B:light(core, { name = "LanternLight", color = MINT, brightness = 0.9, range = 9 })
				B:trail(lan, v(5.4, 4.2, -3.7), v(5.4, 5.8, -3.7), { name = "LanternTrail", color = MINT, life = 0.2, trans = { 0.6, 1 } })
			end
		end)

		------------------------------------------------------------------
		-- Floating voxel cubes (indigo cubes with a mint band + little skull cubes)
		------------------------------------------------------------------
		local orbit = B:bone("Orbit", "Root", v(0, 9, 0))
		local spots = {
			{ 8.6, 11.2, 1.5, "skull" },
			{ -8.2, 9.5, 2.5, "dark" },
			{ 5.5, 5.2, 6.8, "dark" },
			{ -6.4, 13.2, -4.6, "skull" },
			{ 5.6, 22.2, 4.2, "dark" },
		}
		for i, s in spots do
			local p = v(s[1], s[2], s[3])
			local ob = B:bone("Orb" .. i, "Orbit", p)
			if s[4] == "skull" then
				B:block(ob, v(1.4, 1.4, 1.4), CFrame.new(p), BONE)
				B:block(ob, v(0.36, 0.36, 0.1), CFrame.new(p + v(-0.3, 0.12, -0.72)), BLACK)
				B:block(ob, v(0.36, 0.36, 0.1), CFrame.new(p + v(0.3, 0.12, -0.72)), BLACK)
			else
				B:block(ob, v(1.6, 1.6, 1.6), CFrame.new(p), ROBE)
				B:block(ob, v(1.7, 0.25, 1.7), CFrame.new(p), MINT, NEON)
			end
		end

		------------------------------------------------------------------
		-- Hidden slash ring, revealed segment by segment during the 360 sweep
		------------------------------------------------------------------
		local SR, SY, N = 16, 9.0, 18
		local slash = B:bone("Slash", "Root", v(0, SY, 0))
		for k = 1, N do
			local a = math.rad((k - 1) * 360 / N)
			local c = CFrame.new(0, SY, 0) * CFrame.Angles(0, a, 0) * CFrame.new(SR, 0, 0)
			B:block(slash, v(1.0, 0.25, 2 * math.pi * SR / N * 0.9), c, MINT, { mat = "Neon", tr = 1, name = "Slash" .. k })
		end
	end,
}
