--!nocheck
-- Great Maw Tree (Flytrap Stage crop #9, Apex): the showpiece of the bog.
-- A giant carnivorous fruit tree in the stud-tree reference style:
-- * a big stepped bog-dirt mound (bone "Soil") with chunky edge blocks, moss
--   pads, stones, grass tufts, two fallen maw-fruits and a murky bog puddle
--   with lily pads, a little pink flower, cattails and rising bubbles
-- * a chunky twisted bark trunk with gnarled roots, moss patches and a green
--   vine spiralling up it; crooked branches into a lush canopy of big rotated
--   studded leaf cubes in three jungle greens
-- * six flytrap PODS hang from the canopy on curly stems (each pod its own
--   bone, pivot at the stem top; its lid its own bone, pivot at the hinge):
--   chunky green lobes, red rims, pink insides, cream cilia teeth, and a juicy
--   red maw-fruit with a glowing neon cap sitting inside each one
-- * a big upright CROWN trap on top of the canopy holds the biggest maw-fruit
-- * fireflies, drifting spores, drool drips, snap spore bursts, bog bubbles,
--   a soft green pulsing light + a pink crown light (motion.luau animates it)
-- No faces/eyes: it is a plant. Blocks only (no wedges / round parts).
return {
	DisplayName = "Great Maw Tree",
	Rarity = "Apex",
	Element = "Bog",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (matches FlytrapDecor / SnapjawFlytrap) -------------------
		local DIRT_DK, DIRT_DK2, DIRT, DIRT_LT = "#3f2516", "#4d2d1a", "#6a4126", "#865634"
		local MUD = "#2e1d12"
		local MOSS, MOSS_DK = "#6cb337", "#4f8f2a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT, STONE_DK = "#8d8174", "#a39787", "#6c6359"
		local BOG, BOG_DK, BOG_LT = "#2f6a50", "#24533f", "#6fb58a"
		local REED, CATTAIL = "#7f8f3a", "#5a3a1e"
		local BARK_DK, BARK, BARK_LT = "#3a2616", "#523620", "#6b4a2c"
		local LF_DK, LF, LF_MID, LF_LT, LF_LIME = "#22803a", "#2f9c40", "#3fb046", "#5cc84a", "#9ad94e"
		local GREEN, GREEN_DK, GREEN_TOP, GREEN_LT = "#3caa3c", "#1f6e2a", "#58c447", "#a6e04c"
		local INSIDE, RIM = "#ff8aa5", "#c92a48"
		local CREAM = "#fff4d2"
		local FRUIT, FRUIT_DK, FRUIT_LT = "#d9142e", "#8e0f22", "#ff4a58"
		local GLOW_PINK, SHINE = "#ff6f8f", "#ffd2da"
		local LIME = "#86ff3c"
		local FLOWER, FLOWER_LT = "#ff7fa8", "#ffd0e0"

		local seed = 909
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end
		local function polar(r, deg)
			local a = rad(deg)
			return math.sin(a) * r, -math.cos(a) * r
		end
		-- CFrame whose local -Z faces outward along polar `deg`
		local function facing(x, y, z, deg)
			return CFrame.new(x, y, z) * CFrame.Angles(0, -rad(deg), 0)
		end

		------------------------------------------------------------------
		-- STEPPED BOG MOUND (bone "Soil", every part named "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function oct(y0, y1, w, color)
			local h, y = y1 - y0, (y0 + y1) / 2
			B:block(soil, v(w, h, w * 0.62), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.62, h + 0.02, w), cf(0, y, 0), color, S)
			B:block(soil, v(w * 0.84, h - 0.03, w * 0.84), cf(0, y, 0), color, S)
		end
		oct(0, 1.0, 16.4, DIRT_DK)
		oct(1.0, 1.9, 12.2, DIRT)
		oct(1.9, 2.6, 7.4, DIRT_LT)
		for i = 0, 14 do
			local a = i * 24 + jit(6)
			local x, z = polar(7.9 + jit(0.3), a)
			local h = 0.9 + rnd() * 0.7
			B:block(soil, v(2.6 + rnd() * 0.8, h, 1.9 + rnd() * 0.5), cf(x, h / 2, z, 0, -a + jit(10), 0),
				i % 3 == 0 and DIRT or (i % 2 == 0 and DIRT_DK2 or DIRT_DK), S)
		end
		for i = 0, 7 do
			local a = i * 45 + 20 + jit(8)
			if not (a > 300 and a < 345) then -- leave the puddle side open
				local x, z = polar(5.8 + jit(0.3), a)
				local h = 0.7 + rnd() * 0.4
				B:block(soil, v(2.1 + rnd() * 0.5, h, 1.6), cf(x, 1.0 + h / 2, z, 0, -a + jit(12), 0), i % 2 == 0 and DIRT or DIRT_DK, S)
			end
		end
		-- moss pads draped over the tier edges
		for _, m in { { 25, 8.0, 1.05, 2.4, MOSS }, { 100, 7.9, 1.05, 2.0, MOSS_DK }, { 160, 8.0, 1.05, 2.2, MOSS }, { 225, 7.9, 1.05, 2.4, MOSS_DK }, { 285, 8.0, 1.05, 2.0, MOSS },
			{ 65, 5.9, 1.95, 1.8, MOSS }, { 195, 5.9, 1.95, 1.9, MOSS }, { 130, 3.6, 2.65, 1.6, MOSS_DK } } do
			local a = rad(m[1])
			local c = CFrame.new(math.sin(a) * m[2], m[3], -math.cos(a) * m[2]) * CFrame.Angles(0, -a, 0)
			B:block(soil, v(m[4], 0.32, 1.4), c * ang(-14, 0, 0), m[5], S)
		end
		-- stones
		for _, s in { { 6.6, 1.2, -3.0, 1.0, 25, STONE }, { 7.3, 1.1, -1.7, 0.7, 10, STONE_LT }, { -6.4, 1.15, 3.6, 0.9, -20, STONE_DK }, { 2.6, 1.0, 7.1, 0.8, 40, STONE }, { -2.2, 2.25, 4.6, 0.7, 15, STONE_LT } } do
			B:block(soil, v(s[4] * 1.25, s[4], s[4]), cf(s[1], s[2], s[3], jit(10), s[5], jit(10)), s[6], S)
		end
		-- tiny grass tufts
		for _, g in { { 8.7, 1.4 }, { 4.2, -7.7 }, { -8.6, -1.2 }, { -3.4, 8.2 }, { 7.0, 5.6 } } do
			B:block(soil, v(0.5, 1.0, 0.5), cf(g[1], 0.5, g[2], 0, jit(30), 0), GRASS, S)
			B:block(soil, v(0.4, 0.7, 0.4), cf(g[1] + 0.35, 0.35, g[2] + 0.25, 0, jit(30), 0), GRASS_DK, S)
		end
		-- two fallen maw-fruits on the mound
		for _, f in { { 4.9, 1.9, 4.2, 1.1, 30 }, { -4.3, 1.9, 4.6, 0.9, -15 } } do
			local fs = f[4]
			B:block(soil, v(fs, fs * 0.8, fs * 0.7), cf(f[1], f[2] + fs * 0.4, f[3], 0, f[5], 0), FRUIT, S)
			B:block(soil, v(fs * 0.7, fs * 0.8 + 0.02, fs), cf(f[1], f[2] + fs * 0.4, f[3], 0, f[5], 0), FRUIT, S)
			B:block(soil, v(fs * 0.5, 0.2, fs * 0.5), cf(f[1], f[2] + fs * 0.85, f[3], 0, f[5], 0), FRUIT_LT, S)
		end

		-- BOG PUDDLE sunk into the front-left of the middle tier
		local PD = 320
		local px, pz = polar(4.7, PD)
		local PC = CFrame.new(px, 1.9, pz) * CFrame.Angles(0, -rad(PD), 0)
		B:block(soil, v(3.6, 0.4, 2.0), PC * CFrame.new(0, -0.14, 0), BOG, S)
		B:block(soil, v(2.6, 0.38, 2.7), PC * CFrame.new(0, -0.15, -0.1), BOG, S)
		B:block(soil, v(1.2, 0.1, 0.4), PC * CFrame.new(0.6, 0.08, -0.4), BOG_LT, S)
		B:block(soil, v(0.7, 0.1, 0.3), PC * CFrame.new(-0.9, 0.08, 0.5), BOG_LT, S)
		B:block(soil, v(0.9, 0.5, 0.9), PC * CFrame.new(-2.0, -0.05, 0.4) * ang(0, 20, 0), MUD, S)
		B:block(soil, v(1.0, 0.45, 0.8), PC * CFrame.new(2.0, -0.05, -0.5) * ang(0, -15, 0), MUD, S)
		B:block(soil, v(1.6, 0.42, 0.8), PC * CFrame.new(0.3, -0.05, -1.55) * ang(0, 8, 0), MUD, S)
		-- lily pads + a little pink flower
		B:block(soil, v(1.1, 0.12, 1.1), PC * CFrame.new(-0.7, 0.1, -0.3) * ang(0, 30, 0), GREEN, S)
		B:block(soil, v(0.8, 0.12, 0.8), PC * CFrame.new(0.9, 0.1, 0.5) * ang(0, -20, 0), GREEN_TOP, S)
		B:block(soil, v(0.45, 0.3, 0.45), PC * CFrame.new(-0.7, 0.3, -0.3) * ang(0, 45, 0), FLOWER, S)
		B:block(soil, v(0.2, 0.2, 0.2), PC * CFrame.new(-0.7, 0.5, -0.3), FLOWER_LT, S)
		-- cattails at the back edge of the puddle
		B:block(soil, v(0.22, 2.2, 0.22), PC * CFrame.new(-1.3, 1.1, 0.9) * ang(0, 0, 7), REED, S)
		B:block(soil, v(0.4, 0.7, 0.4), PC * CFrame.new(-1.44, 2.0, 0.9) * ang(0, 0, 7), CATTAIL, S)
		B:block(soil, v(0.22, 1.6, 0.22), PC * CFrame.new(-0.85, 0.8, 1.05) * ang(-6, 0, -9), REED, S)
		B:block(soil, v(0.36, 0.6, 0.36), PC * CFrame.new(-0.77, 1.5, 1.08) * ang(-6, 0, -9), CATTAIL, S)
		local bub = B:block(soil, v(2.2, 0.1, 1.6), PC * CFrame.new(0, 0.1, 0), BOG, { tr = 1, name = "Soil" })
		B:emitter(bub, "bubble", { name = "BogBubbles", color = { "#d6ffc0", LIME }, rate = 2, size = { 0.18, 0.32, 0.45 }, speed = { 0.4, 0.9 } })

		------------------------------------------------------------------
		-- TWISTED MOSSY TRUNK (bone "Crop")
		------------------------------------------------------------------
		local BASE = 2.6
		local crop = B:bone("Crop", "Root", v(0, BASE, 0))
		B:block(crop, v(4.8, 1.0, 4.8), cf(0, BASE + 0.4, 0, 0, 10, 0), BARK_DK)
		B:block(crop, v(4.2, 1.0, 4.2), cf(0, BASE + 1.3, 0, 0, -12, 0), BARK)
		-- gnarled roots running down the mound
		for k = 0, 4 do
			local a = k * 72 + 56 + jit(8)
			local x1, z1 = polar(2.2, a)
			local x2, z2 = polar(4.4, a + 12)
			local x3, z3 = polar(5.7, a + 20)
			B:bar(crop, v(x1, BASE + 0.9, z1), v(x2, BASE - 0.2, z2), 1.3, 1.0, (k % 2 == 0) and BARK or BARK_DK)
			B:bar(crop, v(x2, BASE - 0.1, z2), v(x3, 1.6, z3), 0.95, 0.8, BARK_DK)
		end
		local col = {
			{ 3.8, 2.2, 0.0, 0.0, 0 },
			{ 3.5, 4.2, 0.2, -0.1, 18 },
			{ 3.2, 6.2, 0.1, 0.1, 36 },
			{ 3.0, 8.2, -0.2, 0.15, 54 },
			{ 2.8, 10.0, -0.1, 0.0, 72 },
		}
		for i, c in col do
			B:block(crop, v(c[1], 2.3, c[1]), cf(c[3], BASE + c[2], c[4], 0, c[5], (i % 2 == 0) and 3 or -2), (i % 2 == 0) and BARK_LT or BARK)
		end
		-- a green vine spiralling up the trunk, with little leaves
		do
			local prev
			for i = 0, 8 do
				local t = i / 8
				local deg = 40 + t * 400
				local rr = 2.0 - t * 0.5
				local x, z = polar(rr, deg)
				local p = v(x, BASE + 1.0 + t * 9.4, z)
				if prev then
					B:bar(crop, prev, p, 0.55, 0.55, (i % 2 == 0) and GREEN or GREEN_DK)
				end
				if i % 3 == 1 then
					local lx, lz = polar(rr + 0.5, deg + 10)
					B:block(crop, v(0.9, 0.18, 0.6), cf(lx, p.Y + 0.1, lz, 0, -deg + 30, 18), GREEN_TOP)
				end
				prev = p
			end
		end
		-- moss patches on the bark
		for _, m in { { 200, 1.75, 3.6, 1.6 }, { 320, 1.6, 6.8, 1.4 }, { 110, 1.5, 8.6, 1.3 } } do
			local x, z = polar(m[2], m[1])
			B:block(crop, v(m[4], 0.9, 0.5), facing(x, BASE + m[3], z, m[1]), MOSS)
			B:block(crop, v(m[4] * 0.6, 0.4, 0.55), facing(x, BASE + m[3] + 0.6, z, m[1]), GREEN_TOP)
		end
		-- crooked branches into the canopy (two segments with an elbow)
		local br = {
			{ 30, 10.4, 3.0, 12.4, 5.4, 13.8 },
			{ 120, 10.0, 3.2, 12.0, 5.6, 13.4 },
			{ 210, 10.6, 2.9, 12.6, 5.3, 14.0 },
			{ 300, 10.2, 3.1, 12.2, 5.5, 13.6 },
		}
		for _, b in br do
			local x0, z0 = polar(0.8, b[1])
			local x1, z1 = polar(b[3], b[1] + 12)
			local x2, z2 = polar(b[5], b[1] - 6)
			local p0, p1, p2 = v(x0, BASE + b[2], z0), v(x1, b[4], z1), v(x2, b[6], z2)
			B:bar(crop, p0, p1, 1.6, 1.6, BARK)
			B:bar(crop, p1, p2, 1.2, 1.2, BARK_LT)
		end

		------------------------------------------------------------------
		-- CANOPY (own bone so it can sway / breathe): big rotated leaf cubes
		------------------------------------------------------------------
		local canopy = B:bone("Canopy", "Crop", v(0, BASE + 10.0, 0))
		local leafDefs = {
			-- deg, r, y, size, colour
			{ 0, 6.0, 14.3, 5.4, LF_MID },
			{ 60, 6.2, 14.5, 5.2, LF },
			{ 120, 6.0, 14.2, 5.5, LF_DK },
			{ 180, 6.2, 14.4, 5.2, LF_MID },
			{ 240, 6.0, 14.3, 5.4, LF },
			{ 300, 6.3, 14.5, 5.1, LF_DK },
			{ 30, 7.6, 15.9, 3.8, LF_LT },
			{ 150, 7.5, 15.8, 3.7, LF_MID },
			{ 270, 7.6, 16.0, 3.8, LF_LT },
			{ 90, 7.3, 15.6, 3.5, LF_MID },
			{ 210, 7.3, 15.7, 3.5, LF_LT },
			{ 330, 7.3, 15.8, 3.6, LF },
			{ 0, 0.0, 15.2, 6.4, LF_DK },
			{ 20, 4.3, 16.6, 5.0, LF_LT },
			{ 95, 4.1, 17.1, 5.0, LF },
			{ 165, 3.9, 17.3, 5.2, LF_MID },
			{ 235, 4.0, 17.0, 5.0, LF_LT },
			{ 305, 4.3, 16.7, 4.8, LF_MID },
			{ 70, 3.3, 18.4, 3.8, LF_LIME },
			{ 180, 3.0, 18.5, 4.0, LF_LT },
			{ 290, 3.3, 18.4, 3.6, LF_LIME },
		}
		for _, c in leafDefs do
			local x, z = polar(c[2], c[1])
			B:block(canopy, v(c[4], c[4], c[4]), cf(x, c[3], z, jit(20), rnd() * 90, jit(20)), c[5])
		end
		-- a few lime "new leaf" caps on the outer cubes for a lit-from-above look
		for _, c in { { 45, 7.2, 17.8, 2.0 }, { 165, 7.0, 17.6, 2.2 }, { 255, 7.0, 17.7, 2.0 } } do
			local x, z = polar(c[2], c[1])
			B:block(canopy, v(c[4], c[4], c[4]), cf(x, c[3], z, jit(15), rnd() * 90, jit(15)), LF_LIME)
		end

		------------------------------------------------------------------
		-- FLYTRAP POD builder. Frame T: hinge at the origin, mouth toward
		-- local -Z, lower lobe below (-Y), lid above (+Y). The lid is built
		-- OPEN at `open` degrees about T's X axis; motion animates from that.
		------------------------------------------------------------------
		local function pod(o)
			local s, T = o.s, o.T
			local body = B:bone(o.name, o.parent, o.pivot)
			local lid = B:bone(o.name .. "Lid", o.name, T)
			local TL = T * CFrame.Angles(rad(o.open), 0, 0)
			local function at(F, x, y, z, rx, ry, rz)
				return F * CFrame.new(x * s, y * s, z * s) * ang(rx or 0, ry or 0, rz or 0)
			end
			local function bk(bone, F, sx, sy, sz, x, y, z, col, rx, ry, rz, opts)
				return B:block(bone, v(sx * s, sy * s, sz * s), at(F, x, y, z, rx, ry, rz), col, opts)
			end
			local tw = math.max(0.22, 0.3 * s)
			local function tooth(bone, F, x, y, z, rx, rz)
				B:block(bone, v(tw, 1.0 * s, tw), at(F, x, y, z, rx, 0, rz), CREAM)
			end
			for _, k in { -1, 1 } do
				local bone, F = body, T
				if k > 0 then
					bone, F = lid, TL
				end
				bk(bone, F, 3.6, 0.2, 3.1, 0, 0.12 * k, -1.85, INSIDE)
				bk(bone, F, 4.2, 0.3, 3.5, 0, 0.3 * k, -1.85, RIM)
				bk(bone, F, 4.0, 0.7, 3.5, 0, 0.75 * k, -1.85, GREEN)
				bk(bone, F, 4.6, 0.6, 2.1, 0, 0.75 * k, -1.85, k > 0 and GREEN or GREEN_DK)
				bk(bone, F, 3.2, 0.5, 2.7, 0, 1.3 * k, -1.75, k > 0 and GREEN_TOP or GREEN_DK)
				bk(bone, F, 2.8, 0.45, 0.4, 0, 0.75 * k, -3.72, GREEN_DK)
				if k > 0 then
					bk(bone, F, 0.3, 0.3, 2.2, 1.0, 1.6, -1.7, GREEN_LT) -- vein speckles
					bk(bone, F, 0.3, 0.3, 1.4, -1.0, 1.6, -2.0, GREEN_LT)
				end
				-- cilia teeth, rows offset half a step so they interlock when shut
				local ty = -0.3 * k
				local front = (k < 0) and { -1.35, -0.45, 0.45, 1.35 } or { -0.9, 0, 0.9 }
				for _, x in front do
					tooth(bone, F, x, ty, -3.95, 24 * k, 0)
				end
				local sideZ = (k < 0) and { -3.0, -1.6 } or { -2.3, -0.9 }
				for _, sd in { -1, 1 } do
					for _, z in sideZ do
						tooth(bone, F, sd * 2.42, ty, z, 0, 24 * k * sd)
					end
				end
			end
			-- hinge blocks
			bk(body, T, 2.6, 1.1, 1.0, 0, -0.55, 0.35, GREEN_DK)
			bk(lid, TL, 2.4, 0.8, 0.8, 0, 0.55, 0.35, GREEN_DK)
			-- the juicy maw-fruit sitting on the lower pad
			local fz = o.fz or -2.0
			bk(body, T, 2.2, 1.0, 1.5, 0, 0.5, fz, FRUIT)
			bk(body, T, 1.5, 1.02, 2.2, 0, 0.5, fz, FRUIT)
			bk(body, T, 1.9, 0.9, 1.9, 0, 0.48, fz, FRUIT_DK, 0, 45, 0)
			local cap = bk(body, T, 1.3, 0.32, 1.3, 0, 1.12, fz, GLOW_PINK, 0, 0, 0, { mat = "Neon", name = "MawGlow" .. o.idx })
			bk(body, T, 0.55, 0.4, 0.12, -0.45, 0.62, fz - 1.12, SHINE, 0, 0, 0, { mat = "Neon", name = "MawShine" .. o.idx })
			-- digest seam: a lime glow line across the lips, shown while shut
			if o.seam then
				bk(body, T, 3.4, 0.16, 0.16, 0, 0.02, -3.82, LIME, 0, 0, 0, { mat = "Neon", tr = 1, name = "Seam" .. o.idx })
			end
			-- curly stem from the pivot (in the canopy) to the back of the hinge
			if o.stem then
				local top = o.pivot
				local hinge = at(T, 0, -0.1, 1.0).Position
				local mid = top:Lerp(hinge, 0.5) + (top - hinge).Unit:Cross(v(0, 1, 0)) * 0.0 + v(0, 0, 0)
				local back = v(top.X - hinge.X, 0, top.Z - hinge.Z)
				back = back.Magnitude > 0.01 and back.Unit or v(0, 0, 1)
				mid = mid + back * 0.45
				B:bar(body, top + v(0, 0.4, 0), mid, 0.5, 0.5, GREEN_DK)
				B:bar(body, mid, hinge, 0.45, 0.45, GREEN)
				B:block(body, v(0.7, 0.7, 0.7), CFrame.new(mid) * ang(0, 30, 0), GREEN_LT)
				-- a small leaf flag at the knee
				B:block(body, v(1.1, 0.16, 0.6), CFrame.new(mid + v(0, 0.2, 0)) * ang(0, -o.deg + 70, 20), GREEN_TOP)
			end
			return body, lid, cap, at
		end

		------------------------------------------------------------------
		-- HANGING PODS (each pivot at its stem top inside the canopy)
		------------------------------------------------------------------
		local PODS = {
			-- deg, top radius, top y, hinge drop, scale, tilt (mouth down)
			{ 15, 5.2, 12.6, 4.9, 0.9, 4 },
			{ 75, 5.6, 12.8, 4.0, 0.8, 2 },
			{ 135, 5.2, 12.6, 4.8, 0.86, 4 },
			{ 195, 5.6, 12.8, 4.2, 0.88, 2 },
			{ 255, 5.2, 12.6, 4.9, 0.84, 4 },
			{ 318, 5.6, 12.8, 4.0, 0.84, 2 },
		}
		local podBones = {}
		for i, d in PODS do
			local x, z = polar(d[2], d[1])
			local top = v(x, d[3], z)
			local hx, hz = polar(d[2] + 1.2, d[1])
			local T = facing(hx, d[3] - d[4], hz, d[1]) * CFrame.Angles(rad(-d[6]), 0, 0)
			local body, _, _, at = pod({ name = "Pod" .. i, parent = "Canopy", pivot = top, T = T, s = d[5], open = 40, idx = i, deg = d[1], stem = true, seam = (i == 1 or i == 4) })
			podBones[i] = { body = body, T = T, s = d[5], at = at }
		end
		-- lime drool on two pods (strand + drop with a drip emitter)
		for _, i in { 2, 5 } do
			local pb = podBones[i]
			local lip = pb.at(pb.T, 0.9, -0.4, -3.8).Position
			B:block(pb.body, v(0.2, 0.9, 0.2), CFrame.new(lip + v(0, -0.4, 0)), LIME, { mat = "Neon" })
			local drop = B:block(pb.body, v(0.4, 0.45, 0.4), CFrame.new(lip + v(0, -0.95, 0)), LIME, { mat = "Neon", name = "DroolDrop" .. i })
			B:emitter(drop, "drip", { name = "DroolDrip" .. i, color = LIME, rate = 0.9, size = { 0.3, 0.25, 0.12 } })
		end
		-- snap spore puffs inside the two snapping pods
		for _, i in { 1, 4 } do
			local pb = podBones[i]
			local fx = B:block(pb.body, v(1.6, 0.4, 1.4), pb.at(pb.T, 0, 0.8, -2.2), GREEN, { tr = 1, name = "SnapFX" .. i })
			B:emitter(fx, "burst", { name = "SnapSpores" .. i, color = { "#f2ffc8", LIME, "#c8ff7a" }, size = { 0.55, 0.4, 0 }, speed = { 4, 9 }, life = { 0.6, 1.2 }, drag = 2.5 })
		end

		------------------------------------------------------------------
		-- CROWN: a big upright maw on the very top holding the biggest fruit
		------------------------------------------------------------------
		local CR = v(0, 20.0, 0.6)
		local CT = CFrame.new(CR) * CFrame.Angles(rad(25), 0, 0)
		-- thick stem + leafy collar the crown sits in (canopy bone)
		B:block(canopy, v(2.0, 2.4, 2.0), CFrame.new(CR + v(0, -1.3, 0.6)) * ang(0, 20, 0), GREEN_DK)
		for i = 0, 4 do
			local a = i * 72 + 10
			local c = CFrame.new(CR + v(0, -0.6, 0.3)) * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0, -1.4) * ang(-30, 0, 0)
			B:block(canopy, v(1.4, 0.35, 1.8), c, (i % 2 == 0) and GREEN_TOP or LF_LIME)
		end
		local crownBody, _, _, cat = pod({ name = "Crown", parent = "Canopy", pivot = CT * CFrame.new(0, -0.6, 0.6), T = CT, s = 0.9, open = 40, idx = 0, deg = 0, stem = false, fz = -2.05 })
		local crownCore = B:block(crownBody, v(0.4, 0.4, 0.4), cat(CT, 0, 0.6, -2.05), FRUIT_DK, { name = "CrownCore", tr = 1 })
		B:emitter(crownCore, "glow", { name = "CrownGlow", color = { GLOW_PINK, "#ffb0c4" }, rate = 1.6, size = { 1.6, 2.4, 0 }, trans = { 0.7, 0.6, 1 } })
		B:light(crownCore, { name = "CrownLight", color = "#ff7d9a", brightness = 1.0, range = 10 })

		------------------------------------------------------------------
		-- VFX: fireflies, drifting spores, one soft green pulsing light
		------------------------------------------------------------------
		local ff = B:block(canopy, v(17, 7, 17), cf(0, 13.5, 0), GREEN, { tr = 1, name = "FireflyZone" })
		B:emitter(ff, "sparkle", { name = "Fireflies", color = { "#e4ff5c", "#fff27a", "#b6ff4a" }, rate = 7, size = { 0.18, 0.5, 0.1 }, life = { 1.6, 3.0 }, speed = { 0.2, 0.7 }, light = 1 })
		local sp = B:block(canopy, v(13, 1, 13), cf(0, 10.5, 0), GREEN, { tr = 1, name = "SporeZone" })
		B:emitter(sp, "glow", { name = "Spores", color = { "#efffb8", "#b8ff7a" }, rate = 4, size = { 0.25, 0.42, 0 }, trans = { 0.15, 0.25, 1 }, life = { 3, 5 }, speed = { 0.2, 0.5 }, accel = { 0.2, 0.35, 0 }, light = 0.8 })
		local lp = B:block(canopy, v(0.4, 0.4, 0.4), cf(0, 11.2, 0), BARK_DK, { tr = 1, name = "MawLightCore" })
		B:light(lp, { name = "MawLight", color = "#9cff5a", brightness = 1.3, range = 18 })
	end,
}
