--!nocheck
-- Starlight Pegasus: chunky stud-built winged pony in the Void Leviathan style.
-- Colour blocking does the detail: pearly WHITE main volumes, a saturated
-- periwinkle SHADE + DEEP for legs/socks/belly/muzzle/feathers, a stepped
-- cyan -> violet -> pink aurora crest + tail, gold hooves/armor, a black mouth
-- with white block teeth and a pink tongue, big cartoon eyes with heavy brows.
-- Neon is only on eyes, tips, thin strips and the little star gem. The big VFX
-- (star flash, shockwave slabs) are hidden parts revealed during the signature.
return {
	DisplayName = "Starlight Pegasus",
	Rarity = "Cosmic",
	Element = "Celestial",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local WHITE, SHADE, DEEP = "#f7f5ff", "#a596f5", "#7d6be0"
		local LAVL = "#cdbfff"
		local PINK, CYAN, LAVD = "#ff6ec7", "#57dcff", "#a77bff"
		local GOLD, GOLDD = "#f2c230", "#c9941c"
		local MOUTH, TOOTH, TONGUE, PUPIL = "#1c1430", "#ffffff", "#ff5c9a", "#1a1240"
		local NEONC, NEONP = "#6ff3ff", "#ff7fe0"

		-- 4-point twinkle star (thin points + diamond core) facing `face` axis
		local function twinkle(bone, c, size, color, coreColor, face, neonCore)
			local t = size * 0.16
			if face == "x" then
				B:block(bone, v(t, size, t * 1.6), c, color)
				B:block(bone, v(t, t * 1.6, size), c, color)
				B:block(bone, v(t * 1.4, size * 0.38, size * 0.38), c * P.ang(45, 0, 0), coreColor, neonCore and { mat = "Neon" } or nil)
			else
				B:block(bone, v(size, t * 1.6, t), c, color)
				B:block(bone, v(t * 1.6, size, t), c, color)
				B:block(bone, v(size * 0.38, size * 0.38, t * 1.4), c * P.ang(0, 0, 45), coreColor, neonCore and { mat = "Neon" } or nil)
			end
		end

		------------------------------------------------------------------
		-- Body (rump, pivots at the hind hips so it can REAR UP) + chest
		------------------------------------------------------------------
		local body = B:bone("Body", "Root", v(0, 7.0, 3.4))
		B:block(body, v(5.2, 4.6, 5.4), cf(0, 7.7, 2.7), WHITE)
		B:block(body, v(4.2, 0.6, 4.0), cf(0, 10.25, 3.0), WHITE)
		B:block(body, v(4.4, 3.4, 0.6), cf(0, 7.9, 5.65), WHITE)
		B:block(body, v(4.6, 0.8, 4.8), cf(0, 5.25, 2.6), SHADE) -- belly band
		B:block(body, v(3.6, 0.4, 3.8), cf(0, 4.75, 2.6), DEEP)
		-- royal gold girth band with little cyan gems
		B:block(body, v(5.6, 5.4, 0.8), cf(0, 7.9, 0.7), GOLD)
		B:sym(function()
			B:block(body, v(0.2, 0.7, 0.7), cf(2.85, 8.4, 0.7, 45, 0, 0), NEONC, { mat = "Neon" })
			B:block(body, v(0.4, 2.0, 4.6), cf(2.62, 6.3, 2.8), SHADE) -- lower flank panel
			B:block(body, v(0.3, 0.5, 4.0), cf(2.72, 5.45, 2.8), DEEP)
			-- twinkle-star "cutie mark" on each flank
			twinkle(body, cf(2.72, 8.6, 3.3), 2.0, PINK, GOLD, "x")
		end)

		local chest = B:bone("Chest", "Body", v(0, 7.6, 0.4))
		B:block(chest, v(5.4, 4.8, 5.0), cf(0, 7.75, -2.0), WHITE)
		B:block(chest, v(4.4, 0.6, 3.6), cf(0, 10.4, -1.4), WHITE)
		B:block(chest, v(4.6, 0.8, 4.4), cf(0, 5.3, -2.1), SHADE)
		-- stepped chest plates (like the reference's belly scales)
		B:block(chest, v(4.4, 1.0, 0.5), cf(0, 6.9, -4.6), LAVL)
		B:block(chest, v(3.6, 1.0, 0.5), cf(0, 5.95, -4.75), SHADE)
		B:block(chest, v(2.6, 0.8, 0.5), cf(0, 5.1, -4.6), DEEP)
		-- gold breast collar with a tiny cyan gem
		B:block(chest, v(5.6, 0.7, 0.7), cf(0, 8.6, -4.3), GOLD)
		B:block(chest, v(1.6, 1.4, 0.4), cf(0, 7.75, -4.75), GOLD)
		B:block(chest, v(0.6, 0.6, 0.2), cf(0, 7.75, -5.0), NEONC, { mat = "Neon" })
		B:sym(function()
			B:block(chest, v(0.4, 2.0, 4.2), cf(2.72, 6.4, -2.1), SHADE)
			B:block(chest, v(0.3, 0.5, 3.6), cf(2.82, 5.55, -2.1), DEEP)
			B:block(chest, v(0.7, 0.7, 3.2), cf(2.75, 8.6, -2.6), GOLD)
		end)
		local aura = B:block(chest, v(6, 5, 8), cf(0, 9, 0), WHITE, { tr = 1, name = "AuraVolume" })
		B:emitter(aura, "sparkle", { name = "Sparkles", color = { "#ffffff", PINK, CYAN }, rate = 4 })

		------------------------------------------------------------------
		-- Neck (2 bones) with stepped periwinkle throat plates
		------------------------------------------------------------------
		local neck1 = B:bone("Neck1", "Chest", v(0, 9.4, -3.6))
		B:block(neck1, v(3.8, 3.4, 3.6), cf(0, 10.6, -4.3), WHITE)
		B:block(neck1, v(2.8, 2.4, 0.5), cf(0, 10.2, -6.2), SHADE)
		local neck2 = B:bone("Neck2", "Neck1", v(0, 11.4, -5.0))
		B:block(neck2, v(3.4, 3.0, 3.2), cf(0, 12.2, -5.6), WHITE)
		B:block(neck2, v(2.4, 2.0, 0.5), cf(0, 11.9, -7.3), LAVL)

		------------------------------------------------------------------
		-- Head: authored at 1x around the pivot, scaled 1.3x for a big cartoon head
		------------------------------------------------------------------
		local HP, HS = v(0, 12.5, -6.3), 1.3
		local function H(x, y, z) return HP + v(x, y, z) * HS end
		local function hcf(x, y, z, rx, ry, rz) return CFrame.new(H(x, y, z)) * P.ang(rx or 0, ry or 0, rz or 0) end
		local function hs(x, y, z) return v(x, y, z) * HS end

		local head = B:bone("Head", "Neck2", HP)
		B:block(head, hs(4.6, 3.8, 4.2), hcf(0, 1.9, -1.2), WHITE) -- skull
		B:block(head, hs(3.6, 1.6, 2.4), hcf(0, -0.6, -2.0), WHITE) -- jowl
		B:block(head, hs(3.2, 2.2, 3.4), hcf(0, -0.1, -4.6), WHITE) -- snout
		B:block(head, hs(2.6, 0.6, 2.4), hcf(0, 1.25, -4.0), WHITE) -- nose bridge step
		B:block(head, hs(3.4, 1.8, 2.0), hcf(0, -0.2, -5.6), SHADE) -- muzzle box
		B:block(head, hs(2.4, 0.5, 1.6), hcf(0, 0.9, -5.4), SHADE) -- muzzle top step
		B:block(head, hs(2.9, 0.3, 3.4), hcf(0, -1.3, -4.6), MOUTH) -- mouth roof
		-- buck teeth
		B:block(head, hs(0.75, 0.85, 0.3), hcf(0.42, -1.65, -6.15), TOOTH)
		B:block(head, hs(0.75, 0.85, 0.3), hcf(-0.42, -1.65, -6.15), TOOTH)
		-- star gem on the forehead: gold setting + neon pink diamond
		B:block(head, hs(1.0, 1.0, 0.3), hcf(0, 3.55, -3.42, 0, 0, 45), GOLD)
		B:block(head, hs(0.55, 0.55, 0.2), hcf(0, 3.55, -3.6, 0, 0, 45), NEONP, { mat = "Neon", name = "StarGem" })
		local starFX = B:block(head, hs(1, 1, 1), hcf(0, 3.6, -4.2), WHITE, { tr = 1, name = "StarFX" })
		B:light(starFX, { name = "StarLight", color = NEONP, brightness = 0.5, range = 8 })
		B:sym(function()
			B:block(head, hs(0.55, 0.3, 0.15), hcf(0.8, 0.3, -6.65), MOUTH) -- nostril
			-- side tooth row (reads from the side view)
			B:block(head, hs(0.4, 0.5, 0.4), hcf(1.22, -1.7, -5.2), TOOTH)
			B:block(head, hs(0.4, 0.4, 0.4), hcf(1.22, -1.65, -4.2), TOOTH)
			-- dark cheek walls so the open mouth reads black, never see-through
			B:block(head, hs(0.3, 1.6, 1.5), hcf(1.15, -2.0, -5.25), MOUTH)
			B:block(head, hs(0.3, 1.2, 1.6), hcf(1.15, -1.8, -3.75), MOUTH)
			B:block(head, hs(0.2, 0.7, 1.2), hcf(2.35, 0.9, -2.2), PINK) -- blush
			-- big cartoon eye on the front corner: sclera, neon iris, pupil, shine
			B:block(head, hs(1.9, 2.2, 1.4), hcf(1.5, 2.2, -3.3), TOOTH)
			B:block(head, hs(1.0, 1.5, 0.2), hcf(1.6, 2.1, -4.05), NEONC, { mat = "Neon", name = "Eye" })
			B:block(head, hs(0.5, 1.0, 0.12), hcf(1.38, 2.0, -4.18), PUPIL)
			B:block(head, hs(0.3, 0.3, 0.1), hcf(1.88, 2.55, -4.19), TOOTH)
			B:block(head, hs(0.12, 1.4, 0.8), hcf(2.5, 2.1, -3.35), NEONC, { mat = "Neon" })
			B:block(head, hs(0.1, 0.9, 0.4), hcf(2.57, 2.0, -3.55), PUPIL)
		end)
		-- hidden 4-point star flash revealed on the neigh
		B:block(head, hs(3.6, 0.3, 0.12), hcf(0, 3.55, -3.85), "#fff4fd", { mat = "Neon", tr = 1, name = "Flash1" })
		B:block(head, hs(0.3, 3.6, 0.12), hcf(0, 3.55, -3.85), "#fff4fd", { mat = "Neon", tr = 1, name = "Flash2" })
		B:block(head, hs(1.7, 0.22, 0.1), hcf(0, 3.55, -3.88, 0, 0, 45), NEONP, { mat = "Neon", tr = 1, name = "Flash3" })
		B:block(head, hs(1.7, 0.22, 0.1), hcf(0, 3.55, -3.88, 0, 0, -45), NEONP, { mat = "Neon", tr = 1, name = "Flash4" })
		B:emitter(starFX, "burst", {
			name = "StarBurst", color = { "#ffffff", NEONP, "#ffe27a", NEONC }, size = { 1.1, 0.7, 0 }, speed = { 7, 14 }, life = { 0.5, 1.0 },
		})
		B:light(starFX, { name = "BurstLight", color = NEONP, brightness = 0, range = 12 })

		-- brows + blink lids (lids only shown while closing)
		B:sym(function(side)
			local lid = B:bone("Lid" .. side, "Head", H(1.5, 3.3, -3.3))
			B:block(lid, hs(1.95, 0.6, 1.5), hcf(1.5, 3.3, -3.35), DEEP) -- heavy brow
			B:block(lid, hs(1.95, 1.9, 0.3), hcf(1.5, 3.05, -4.12), WHITE, { tr = 1, name = "Eyelid" .. side })
			B:block(lid, hs(2.05, 0.3, 0.35), hcf(1.5, 2.15, -4.15), DEEP, { tr = 1, name = "Lash" .. side })
		end)

		-- ears: stepped voxel triangles with a pink inner block
		B:sym(function(side)
			local EF = hcf(1.45, 3.4, -0.3, 0, 0, -18)
			local ear = B:bone("Ear" .. side, "Head", EF)
			B:block(ear, hs(1.4, 1.4, 1.0), EF * CFrame.new(hs(0, 0.7, 0)), WHITE)
			B:block(ear, hs(1.0, 0.9, 0.8), EF * CFrame.new(hs(0, 1.75, 0.05)), WHITE)
			B:block(ear, hs(0.7, 0.6, 0.6), EF * CFrame.new(hs(0, 2.45, 0.1)), SHADE)
			B:block(ear, hs(0.4, 0.4, 0.4), EF * CFrame.new(hs(0, 2.9, 0.15)), DEEP)
			B:block(ear, hs(0.8, 1.6, 0.25), EF * CFrame.new(hs(0, 1.0, -0.6)), PINK)
		end)

		-- jaw (hinges at the back of the mouth)
		local jaw = B:bone("Jaw", "Head", H(0, -1.2, -2.8))
		B:block(jaw, hs(2.9, 0.9, 3.9), hcf(0, -2.05, -4.35), WHITE)
		B:block(jaw, hs(2.4, 0.4, 3.0), hcf(0, -2.6, -4.6), SHADE) -- chin
		B:block(jaw, hs(2.5, 0.2, 3.3), hcf(0, -1.55, -4.6), MOUTH)
		B:block(jaw, hs(1.8, 0.3, 2.4), hcf(0, -1.5, -4.4), TONGUE)
		B:block(jaw, hs(2.6, 2.2, 1.0), hcf(0, -1.2, -3.1), MOUTH) -- throat back wall
		B:sym(function()
			B:block(jaw, hs(0.3, 1.1, 3.0), hcf(1.15, -1.15, -4.5), MOUTH) -- cheek wall
			B:block(jaw, hs(0.4, 0.45, 0.4), hcf(1.15, -1.38, -5.7), TOOTH)
			B:block(jaw, hs(0.4, 0.4, 0.4), hcf(1.15, -1.4, -4.7), TOOTH)
		end)

		------------------------------------------------------------------
		-- Aurora crest: stepped sawtooth on every mane bone, cyan -> violet ->
		-- pink, plus a stepped mane fall down the right side of the neck
		------------------------------------------------------------------
		local function crest(bone, x, y, z, s)
			B:block(bone, v(2.2, 1.2, 2.4) * s, cf(x, y, z), CYAN)
			B:block(bone, v(1.8, 1.2, 2.0) * s, cf(x, y + 1.0 * s, z + 0.5 * s), LAVD)
			B:block(bone, v(1.2, 1.0, 1.4) * s, cf(x, y + 1.9 * s, z + 1.0 * s), PINK)
		end
		local function fall(bone, x, y, z)
			B:block(bone, v(0.8, 1.6, 2.0), cf(x, y, z), CYAN)
			B:block(bone, v(0.8, 1.4, 1.6), cf(x + 0.1, y - 1.3, z + 0.25), LAVD)
			B:block(bone, v(0.8, 1.0, 1.2), cf(x + 0.15, y - 2.35, z + 0.45), PINK)
		end
		local m1 = B:bone("Mane1", "Chest", v(0, 10.6, -1.6))
		crest(m1, 0, 11.1, -1.5, 1.0)
		local m2 = B:bone("Mane2", "Neck1", v(0, 12.0, -3.2))
		crest(m2, 0, 12.6, -4.0, 1.05)
		fall(m2, 2.05, 12.1, -3.9)
		local m3 = B:bone("Mane3", "Neck2", v(0, 13.5, -5.0))
		crest(m3, 0, 14.3, -5.0, 1.15)
		fall(m3, 1.95, 13.4, -5.2)
		local m4 = B:bone("Mane4", "Head", H(0, 3.8, -0.8))
		-- forelock: 3-step pompadour curling forward, pink tip above the star gem
		B:block(m4, hs(2.4, 1.0, 1.8), hcf(0, 3.9, 0.3), CYAN)
		B:block(m4, hs(2.8, 1.0, 2.4), hcf(0, 4.25, -1.2), CYAN)
		B:block(m4, hs(2.2, 1.0, 2.0), hcf(0, 4.95, -2.2), LAVD)
		B:block(m4, hs(1.5, 0.9, 1.4), hcf(0, 4.8, -3.45), PINK)

		------------------------------------------------------------------
		-- Legs: upper / lower / hoof (3 bones each). White leg, deep sock,
		-- violet fetlock tuft, chunky gold hoof.
		------------------------------------------------------------------
		local function leg(prefix, parent, x, z, upperH, side)
			local up = B:bone(prefix .. "Leg" .. side, parent, v(x, 7.0, z))
			B:block(up, v(2.3, upperH, 2.5), cf(x, 7.3 - upperH / 2, z), WHITE)
			B:block(up, v(2.4, 0.8, 2.6), cf(x, 7.3 - upperH + 0.5, z), SHADE)
			local knee = B:bone(prefix .. "Knee" .. side, prefix .. "Leg" .. side, v(x, 4.1, z))
			B:block(knee, v(1.8, 2.9, 1.8), cf(x, 2.75, z), WHITE)
			B:block(knee, v(1.9, 1.2, 1.9), cf(x, 1.9, z), DEEP) -- sock
			local hoof = B:bone(prefix .. "Hoof" .. side, prefix .. "Knee" .. side, v(x, 1.4, z))
			B:block(hoof, v(2.3, 0.8, 2.3), cf(x, 1.65, z), LAVD) -- fetlock tuft
			B:block(hoof, v(2.5, 1.3, 2.7), cf(x, 0.65, z - 0.1), GOLD)
			B:block(hoof, v(2.6, 0.25, 0.2), cf(x, 0.95, z - 1.5), NEONC, { mat = "Neon" })
			B:block(hoof, v(2.7, 0.4, 2.9), cf(x, 0.2, z - 0.1), GOLDD)
			return hoof
		end
		B:sym(function(side)
			local fh = leg("F", "Chest", 1.75, -2.6, 3.4, side)
			B:block("FLeg" .. side, v(1.0, 0.8, 0.3), cf(1.75, 4.3, -3.9), GOLD) -- knee guard
			B:trail(fh, v(1.75, 0.2, -2.6), v(1.75, 1.6, -2.6), { name = "HoofTrail" .. side, color = { NEONC, NEONP }, life = 0.25, trans = { 0.45, 1 } })
			leg("H", "Body", 1.85, 3.9, 3.6, side)
		end)
		-- stomp FX: dust + voxel cube burst between the front hooves
		local dustAt = B:block("Root", v(5, 0.2, 3), cf(0, 0.1, -2.8), WHITE, { tr = 1, name = "StompFX" })
		B:emitter(dustAt, "dust", { name = "StompDust", color = "#efe9ff" })
		B:emitter(dustAt, "burst", { name = "StompCubes", tex = "smoke", color = { PINK, CYAN, LAVD }, speed = { 10, 18 }, size = { 0.8, 0.6, 0 }, life = { 0.5, 0.9 } })
		-- shockwave: a ring of flat aurora slabs (one bone each), hidden until the stomp
		local SC = v(0, 0.2, -2.6)
		for k = 1, 12 do
			local a = (k - 1) / 12 * 360
			local sb = B:bone("Shock" .. k, "Root", SC)
			B:block(sb, v(2.2, 0.4, 0.9), CFrame.new(SC) * P.ang(0, a, 0) * CFrame.new(0, 0, -2.6), k % 2 == 0 and PINK or LAVD, { tr = 1, name = "Wave" .. k })
		end

		------------------------------------------------------------------
		-- Aurora tail (4 bones): cyan root -> violet -> pink tip
		------------------------------------------------------------------
		local t1 = B:bone("Tail1", "Body", v(0, 9.8, 5.4))
		B:block(t1, v(1.8, 1.8, 2.2), cf(0, 10.7, 6.4), CYAN)
		B:block(t1, v(1.4, 0.8, 1.6), cf(0, 11.9, 6.6), LAVD)
		local t2 = B:bone("Tail2", "Tail1", v(0, 11.0, 7.4))
		B:block(t2, v(2.4, 2.4, 2.2), cf(0, 11.4, 8.4), CYAN)
		B:block(t2, v(1.8, 0.8, 1.8), cf(0, 13.0, 8.6), LAVD)
		B:block(t2, v(1.8, 0.8, 1.6), cf(0, 9.9, 8.8), LAVD)
		local t3 = B:bone("Tail3", "Tail2", v(0, 10.6, 9.4))
		B:block(t3, v(2.6, 2.6, 2.2), cf(0, 9.6, 10.3), LAVD)
		B:block(t3, v(2.2, 1.8, 0.6), cf(0, 9.8, 11.6), PINK)
		B:block(t3, v(2.0, 0.8, 1.6), cf(0, 8.0, 10.5), LAVD)
		local t4 = B:bone("Tail4", "Tail3", v(0, 8.4, 10.6))
		B:block(t4, v(2.4, 2.2, 2.0), cf(0, 7.0, 10.9), PINK)
		B:block(t4, v(1.8, 1.6, 1.6), cf(0, 5.3, 11.1), PINK)
		B:block(t4, v(1.2, 1.2, 1.2), cf(0, 4.0, 11.2), LAVD)
		B:block(t4, v(0.6, 0.6, 0.6), cf(0, 3.2, 11.25), NEONP, { mat = "Neon" })
		B:trail(t4, v(0, 3.6, 11.2), v(0, 5.8, 11.1), { name = "TailTrail", color = { PINK, CYAN }, life = 0.3, trans = { 0.5, 1 } })

		------------------------------------------------------------------
		-- Wings: 3 bones each. White arm + leading-edge step, white coverts,
		-- periwinkle feathers with deep tips and aurora accent tips.
		-- Authored in a wing frame: local X = along the arm, local Z = feathers.
		------------------------------------------------------------------
		B:sym(function(side)
			local E, SW = math.rad(44), math.rad(42)
			local u1 = v(math.cos(SW), 0, math.sin(SW))
			local up = v(0, 1, 0)
			local ax = u1 * math.cos(E) + up * math.sin(E)
			local fz = u1 * math.sin(E) - up * math.cos(E)
			local W1 = CFrame.fromMatrix(v(2.2, 10.4, -1.0), ax, fz:Cross(ax), fz)
			local W2 = W1 * CFrame.new(4.6, 0, 0) * P.ang(0, 4, 0)
			local W3 = W2 * CFrame.new(4.2, 0, 0) * P.ang(0, -12, 0)
			local function feathers(bone, F, list)
				for i, f in list do
					local len = f[2]
					local dy = (i % 2 == 0) and -0.06 or -0.14
					B:block(bone, v(1.6, 0.7, len), F * CFrame.new(f[1], dy, 2.0 + len / 2), SHADE)
					B:block(bone, v(1.5, 0.6, 1.3), F * CFrame.new(f[1], dy - 0.02, 2.0 + len + 0.45), f[3] or DEEP)
				end
			end
			local w1 = B:bone("Wing1" .. side, "Chest", W1.Position)
			B:block(w1, v(5.0, 1.4, 1.6), W1 * CFrame.new(2.3, 0, 0), WHITE)
			B:block(w1, v(4.4, 1.0, 1.0), W1 * CFrame.new(2.5, 0.6, -0.2), WHITE) -- leading-edge step
			B:block(w1, v(1.8, 1.7, 1.9), W1 * CFrame.new(0.5, 0.05, 0.1), GOLD)
			B:block(w1, v(4.4, 1.0, 2.4), W1 * CFrame.new(2.6, 0.15, 1.7), WHITE)
			feathers(w1, W1, { { 1.2, 2.6 }, { 2.8, 3.2, LAVD }, { 4.4, 3.8 } })
			local w2 = B:bone("Wing2" .. side, "Wing1" .. side, W2.Position)
			B:block(w2, v(4.6, 1.3, 1.5), W2 * CFrame.new(2.0, 0, 0), WHITE)
			B:block(w2, v(4.0, 1.0, 1.0), W2 * CFrame.new(2.0, 0.55, -0.2), WHITE)
			B:block(w2, v(4.4, 1.0, 2.4), W2 * CFrame.new(2.1, 0.15, 1.7), WHITE)
			B:block(w2, v(3.8, 0.25, 0.25), W2 * CFrame.new(2.0, 0.6, -0.75), NEONC, { mat = "Neon" })
			feathers(w2, W2, { { 0.9, 4.4, PINK }, { 2.5, 5.0 }, { 4.1, 5.6, CYAN } })
			local w3 = B:bone("Wing3" .. side, "Wing2" .. side, W3.Position)
			B:block(w3, v(4.6, 1.2, 1.4), W3 * CFrame.new(2.1, 0, -0.1), WHITE)
			B:block(w3, v(3.6, 0.9, 0.9), W3 * CFrame.new(1.9, 0.5, -0.3), WHITE)
			B:block(w3, v(4.0, 0.9, 2.0), W3 * CFrame.new(2.0, 0.15, 1.5), WHITE)
			B:block(w3, v(0.7, 0.7, 0.7), W3 * CFrame.new(4.5, 0.1, -0.1), NEONP, { mat = "Neon" })
			feathers(w3, W3, { { 0.8, 6.2 }, { 2.4, 7.1, PINK }, { 4.0, 5.4 } })
			local wfx = B:block(w3, v(1.2, 1.2, 3.0), W3 * CFrame.new(3.0, 0, 5.0), WHITE, { tr = 1, name = "WingFX" .. side })
			B:emitter(wfx, "sparkle", { name = "WingSparks" .. side, color = { "#ffffff", NEONP, NEONC }, rate = 14, size = { 0.3, 0.7, 0 }, speed = { 1, 4 }, enabled = false })
			B:trail(w3, (W3 * CFrame.new(4.4, 0, 0)).Position, (W3 * CFrame.new(3.0, 0, 9.0)).Position, { name = "WingTrail" .. side, color = { NEONC, NEONP }, life = 0.3, trans = { 0.6, 1 } })
		end)

		------------------------------------------------------------------
		-- Floating voxel cubes + a gold twinkle star on clear spots (VFX)
		------------------------------------------------------------------
		B:bone("Orbit", "Root", v(0, 9, 1))
		local spots = {
			{ 12.5, 6.5, -3.0, PINK, NEONC },
			{ -12.5, 6.0, -1.5, CYAN, NEONP },
			{ 11.5, 16.5, -9.5, LAVD, NEONC },
			{ -11.5, 15.5, -10.0, PINK, NEONC },
			{ 0, 21.4, 9.0 },
		}
		for i, s in spots do
			local ob = B:bone("Orb" .. i, "Orbit", v(s[1], s[2], s[3]))
			if s[4] then
				local sz = (i == 2 or i == 4) and 1.5 or 1.8
				B:block(ob, v(sz, sz, sz), cf(s[1], s[2], s[3]), s[4])
				B:block(ob, v(sz + 0.1, sz * 0.3, sz + 0.1), cf(s[1], s[2] + sz * 0.36, s[3]), WHITE)
				B:block(ob, v(sz + 0.16, sz * 0.16, sz + 0.16), cf(s[1], s[2] - sz * 0.08, s[3]), s[5], { mat = "Neon" })
			else
				twinkle(ob, cf(s[1], s[2], s[3]), 2.4, GOLD, "#fff6c8", "z", true)
			end
		end
	end,
}
