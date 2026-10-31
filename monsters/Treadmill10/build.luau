-- Treadmill10 "Lava Treadmill" (Legendary): obsidian rock frame with a lava-glow belt
-- (molten bed + glowing seams), flowing lava channels, pulsing magma vents with piston
-- caps, jagged obsidian spires, a smoking volcano crown with orbiting lava rocks,
-- stone drive gears and embers. Lava is bright plastic colour blocking; neon only for
-- the hottest cores. Faces -Z (console at the front). Belt slats slide +Z on "Belt".
return {
	DisplayName = "Lava Treadmill",
	Rarity = "Legendary",
	Element = "Fire",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local O1, O2, O3 = "#211828", "#3a2c48", "#57456c" -- obsidian dark / main / light
		local O4 = "#7c6992" -- obsidian sheen
		local LD, LA, LB, LC = "#c8361a", "#ff6a1c", "#ff9c34", "#ffd45a" -- lava plastic
		local NA, NB, NR = "#ff8a1f", "#ffc23a", "#ff3a1a" -- neon cores
		local neon = { mat = "Neon" }
		local function N(name) return { mat = "Neon", name = name } end

		---------------------------------------------------------------- base
		B:block("Root", v(6.0, 0.35, 10.0), cf(0, 0.175, 0), O1)
		local chunks = {
			{ 2.9, 0.3, -4.6, 1.2, 0.6, 1.0 }, { -2.95, 0.28, -4.4, 1.0, 0.56, 1.3 }, { 2.95, 0.3, 4.7, 1.1, 0.6, 1.1 },
			{ -2.9, 0.26, 4.5, 1.3, 0.52, 1.0 }, { 3.05, 0.22, 0.6, 0.6, 0.44, 1.6 }, { -3.05, 0.22, -0.8, 0.6, 0.44, 1.8 },
		}
		for _, k in chunks do
			B:block("Root", v(k[4], k[5], k[6]), cf(k[1], k[2], k[3]), O2)
		end
		B:block("Root", v(5.3, 0.75, 9.7), cf(0, 0.72, 0), O2)
		B:block("Root", v(5.4, 0.14, 9.8), cf(0, 1.12, 0), O3)
		B:block("Root", v(5.45, 0.16, 9.85), cf(0, 0.5, 0), LD)
		-- outer channel walls
		B:sym(function()
			B:block("Root", v(0.3, 0.95, 8.2), cf(3.2, 0.8, 0), O3)
			B:block("Root", v(0.38, 0.12, 8.0), cf(3.2, 1.32, 0), LD)
			B:block("Root", v(0.44, 0.45, 1.2), cf(3.25, 0.85, -1.9), O2)
			B:block("Root", v(0.44, 0.5, 1.0), cf(3.25, 0.8, 2.3), O2)
			-- channel bed: molten crust
			B:block("Root", v(0.62, 0.1, 7.6), cf(2.88, 1.2, 0), LB)
			B:block("Root", v(0.66, 0.2, 7.7), cf(2.88, 1.08, 0), LD)
		end)
		-- lava cracks down the channel walls (pulse)
		for i, z in { -1.28, 0.72 } do
			for _, s in { 1, -1 } do
				local x = s * 3.37
				B:block("Root", v(0.06, 0.14, 0.62), cf(x, 1.12, z), LA)
				B:block("Root", v(0.06, 0.4, 0.14), cf(x, 0.86, z + 0.26), LA)
				B:block("Root", v(0.06, 0.12, 0.5), cf(x, 0.66, z + 0.45), LD)
				B:block("Root", v(0.08, 0.06, 0.4), cf(x + s * 0.01, 1.12, z), NB, N(("Crack%s%d"):format(s == 1 and "R" or "L", i)))
			end
		end

		-- flowing lava in the side channels (blobs slide toward the back)
		for _, s in { 1, -1 } do
			local flow = B:bone(s == 1 and "FlowR" or "FlowL", "Root", v(s * 2.88, 1.26, 0))
			for k = 0, 7 do
				local z = -3.6 + k * 1.0
				B:block(flow, v(0.5, 0.06, 0.62), cf(s * 2.88, 1.27, z), k % 2 == 0 and NB or NA, neon)
				B:block(flow, v(0.36, 0.05, 0.25), cf(s * 2.88, 1.275, z + 0.5), LB)
			end
		end

		-- molten belt bed glows through the gaps, obsidian slats, glowing seams
		B:block("Root", v(3.5, 0.1, 7.8), cf(0, 1.2, 0.25), LA)
		local belt = B:bone("Belt", "Root", v(0, 1.3, 0))
		local seam = 0
		for i = 0, 15 do
			local z = -3.6 + i * 0.5
			B:block(belt, v(3.4, 0.07, 0.27), cf(0, 1.285, z), i % 2 == 0 and O3 or O2)
			if i % 2 == 0 then
				seam += 1
				B:block(belt, v(3.3, 0.05, 0.08), cf(0, 1.27, z + 0.25), seam % 2 == 0 and NB or NA, N("Seam" .. seam))
			end
		end

		-- foot rails: obsidian with rough knobs
		B:sym(function()
			B:block("Root", v(0.8, 0.34, 7.6), cf(2.15, 1.32, 0.25), O3)
			B:block("Root", v(0.55, 0.08, 7.4), cf(2.2, 1.52, 0.25), O4)
			for _, z in { -2.6, -0.2, 2.2 } do
				B:block("Root", v(0.5, 0.18, 0.7), cf(2.3, 1.6, z), O2)
				B:block("Root", v(0.52, 0.06, 0.12), cf(2.3, 1.62, z + 0.1), LB)
			end
			B:block("Root", v(0.06, 0.06, 7.2), cf(1.77, 1.42, 0.25), NA, neon)
		end)

		-- stone drive gears on the channel walls (spin)
		for i, z in { -2.9, 0.15, 3.2 } do
			for _, s in { 1, -1 } do
				local nm = ("Gear%d%s"):format(i, s == 1 and "R" or "L")
				local x = s * 3.43
				local b = B:bone(nm, "Root", v(x, 0.82, z))
				local c = cf(x, 0.82, z)
				B:block(b, v(0.14, 0.95, 0.3), c, O4)
				B:block(b, v(0.14, 0.3, 0.95), c, O4)
				B:block(b, v(0.16, 0.6, 0.6), c * ang(45, 0, 0), O2)
				B:block(b, v(0.18, 0.34, 0.34), c, LB)
				B:block(b, v(0.22, 0.18, 0.18), c, NB, neon)
			end
		end

		-- front hood with a molten grille
		B:block("Root", v(5.3, 1.1, 1.6), cf(0, 1.65, -4.1), O2)
		B:block("Root", v(5.0, 0.3, 1.4), cf(0, 2.35, -4.1), O3)
		-- molten pool on the hood, fed by the lavafall from the volcano
		B:block("Root", v(3.8, 0.16, 1.2), cf(0, 2.56, -4.1), O1)
		B:block("Root", v(3.4, 0.08, 0.9), cf(0, 2.66, -4.1), LB)
		B:block("Root", v(2.8, 0.06, 0.65), cf(0, 2.71, -4.12), NB, N("Pool"))
		B:block("Root", v(0.5, 0.06, 0.3), cf(-1.2, 2.72, -3.9), LC)
		B:block("Root", v(0.4, 0.06, 0.25), cf(1.3, 2.72, -4.35), LD)
		-- lavafall: molten sheet + bright drops sliding down (one gap per step, seamless)
		B:block("Root", v(0.9, 3.0, 0.12), cf(0, 4.1, -4.58), LA)
		B:block("Root", v(1.2, 3.0, 0.1), cf(0, 4.1, -4.5), LD)
		local fall = B:bone("Fall", "Root", v(0, 4.1, -4.66))
		for k = 0, 6 do
			for col = -1, 1 do
				local y = 2.6 + k * 0.5 + ((col + 1) % 3) * 0.17
				local hot = (k + col) % 2 == 0
				B:block(fall, v(0.18, 0.3, 0.06), cf(col * 0.28, y, -4.67), hot and NA or NR, neon)
			end
		end
		B:block("Root", v(0.3, 2.9, 0.04), cf(0, 4.1, -4.65), NA, N("FallCore"))
		B:block("Root", v(3.0, 0.8, 0.1), cf(0, 1.65, -4.93), LA)
		for r = 0, 3 do
			B:block("Root", v(3.1, 0.1, 0.12), cf(0, 1.29 + r * 0.24, -4.98), O1)
		end
		for r = 1, 3 do
			B:block("Root", v(2.7, 0.06, 0.06), cf(0, 1.29 + r * 0.24 - 0.12, -5.0), r == 2 and NB or NA, N("Grille" .. r))
		end
		B:block("Root", v(0.35, 1.0, 0.2), cf(-1.65, 1.65, -4.98), O3)
		B:block("Root", v(0.35, 1.0, 0.2), cf(1.65, 1.65, -4.98), O3)
		-- rear cap
		B:block("Root", v(5.3, 0.65, 0.9), cf(0, 1.35, 4.45), O2)
		B:block("Root", v(5.35, 0.14, 0.95), cf(0, 1.72, 4.45), O3)
		B:block("Root", v(3.6, 0.3, 0.06), cf(0, 1.35, 4.92), LA)
		B:block("Root", v(3.4, 0.06, 0.06), cf(0, 1.35, 4.96), NB, neon)

		--------------------------------------------------------- magma vents
		local vents = { { 1, -4.3, 1.0, "R1" }, { -1, -4.3, 1.0, "L1" }, { 1, 4.35, 2.4, "R2" }, { -1, 4.35, 2.4, "L2" } }
		local ventTops = {}
		for _, vt in vents do
			local s, z, hgt, id = vt[1], vt[2], vt[3], vt[4]
			local x = s * 3.0
			B:block("Root", v(1.3, 0.7, 1.3), cf(x, 0.55, z), O2)
			B:block("Root", v(1.1, hgt, 1.1), cf(x, 0.9 + hgt / 2, z), O3)
			B:block("Root", v(1.18, 0.2, 1.18), cf(x, 0.95 + hgt * 0.5, z), LD)
			local top = 0.9 + hgt
			B:block("Root", v(1.25, 0.25, 1.25), cf(x, top + 0.12, z), O1)
			B:block("Root", v(0.9, 0.06, 0.9), cf(x, top + 0.23, z), LB)
			B:block("Root", v(0.75, 0.06, 0.75), cf(x, top + 0.27, z), NB, N("VentCore" .. id))
			-- molten vein down the outer face
			B:block("Root", v(0.06, hgt * 0.7, 0.16), cf(x + s * 0.56, 0.9 + hgt * 0.45, z - 0.15), LA)
			B:block("Root", v(0.06, 0.14, 0.4), cf(x + s * 0.56, 0.9 + hgt * 0.1, z - 0.02), LA)
			B:block("Root", v(0.08, hgt * 0.5, 0.06), cf(x + s * 0.57, 0.9 + hgt * 0.45, z - 0.15), NA, neon)
			-- piston cap that pops up on each puff
			local cap = B:bone("Cap" .. id, "Root", v(x, top + 0.4, z))
			B:block(cap, v(0.9, 0.16, 0.9), cf(x, top + 0.45, z), O4)
			B:block(cap, v(0.6, 0.14, 0.6), cf(x, top + 0.6, z), O2)
			B:block(cap, v(0.14, 0.4, 0.14), cf(x, top + 0.25, z), O1)
			ventTops[id] = v(x, top + 0.2, z)
		end
		-- jagged obsidian spires around the tall rear vents, lava-veined, glowing tips
		for _, s in { 1, -1 } do
			local x, z = s * 3.0, 4.35
			local sp = {
				{ v(x + s * 0.4, 1.2, z + 0.3), v(x + s * 1.2, 4.6, z + 0.9), 0.55, O3 },
				{ v(x + s * 0.5, 1.2, z - 0.3), v(x + s * 1.1, 3.3, z - 1.0), 0.45, O2 },
				{ v(x - s * 0.2, 1.4, z + 0.5), v(x - s * 0.05, 6.0, z + 1.0), 0.5, O4 },
			}
			for j, q in sp do
				B:bar("Root", q[1], q[2], q[3], q[3], q[4])
				local tip = q[2]
				local dir = (q[2] - q[1]).Unit
				B:bar("Root", tip - dir * 0.5, tip + dir * 0.05, q[3] * 0.6, q[3] * 0.6, LA)
				B:bar("Root", tip - dir * 0.25, tip + dir * 0.12, q[3] * 0.35, q[3] * 0.35, NB, N(("SpireTip%s%d"):format(s == 1 and "R" or "L", j)))
			end
			B:bar("Root", v(x + s * 0.72, 2.5, z + 0.62), v(x + s * 1.05, 4.1, z + 0.92), 0.12, 0.3, LA)
			B:bar("Root", v(x - s * 0.06, 3.0, z + 0.72), v(x - s * 0.02, 4.8, z + 0.92), 0.3, 0.12, LA)
		end

		------------------------------------------------------------- pillars
		for _, s in { 1, -1 } do
			local x = s * 2.15
			local stack = { { 1.3, 0.9, 1.4, 2.95, 0 }, { 1.05, 1.1, 1.15, 3.95, 0.08 }, { 1.15, 0.9, 1.2, 4.95, -0.05 }, { 0.95, 0.9, 1.05, 5.8, 0.06 } }
			for j, st in stack do
				B:block("Root", v(st[1], st[2], st[3]), cf(x + s * st[5], st[4], -4.1 + (j % 2) * 0.08), j % 2 == 0 and O3 or O2)
			end
			B:block("Root", v(1.4, 0.18, 1.5), cf(x, 3.42, -4.1), LD)
			B:block("Root", v(1.25, 0.14, 1.3), cf(x, 5.42, -4.1), LD)
			-- zig-zag molten vein on the outer face with hot neon cores
			local sd = s == 1 and "R" or "L"
			B:block("Root", v(0.06, 0.8, 0.16), cf(x + s * 0.66, 2.95, -4.3), LA)
			B:block("Root", v(0.06, 0.14, 0.5), cf(x + s * 0.6, 3.55, -4.1), LA)
			B:block("Root", v(0.06, 0.9, 0.16), cf(x + s * 0.61, 4.0, -3.9), LA)
			B:block("Root", v(0.06, 0.14, 0.4), cf(x + s * 0.63, 4.5, -4.05), LA)
			B:block("Root", v(0.06, 0.7, 0.16), cf(x + s * 0.63, 4.9, -4.2), LA)
			B:block("Root", v(0.08, 0.6, 0.06), cf(x + s * 0.67, 2.95, -4.3), NB, N("Vein" .. sd .. "1"))
			B:block("Root", v(0.08, 0.7, 0.06), cf(x + s * 0.62, 4.0, -3.9), NB, N("Vein" .. sd .. "2"))
			B:block("Root", v(0.08, 0.5, 0.06), cf(x + s * 0.64, 4.9, -4.2), NB, N("Vein" .. sd .. "3"))
			-- obsidian shards jutting from the pillars
			B:bar("Root", v(x + s * 0.4, 4.4, -4.4), v(x + s * 1.3, 5.5, -4.8), 0.4, 0.4, O4)
			B:bar("Root", v(x + s * 0.4, 3.1, -4.6), v(x + s * 1.1, 3.8, -5.1), 0.34, 0.34, O3)
			B:bar("Root", v(x + s * 0.3, 5.6, -4.3), v(x + s * 0.9, 6.7, -4.5), 0.3, 0.3, O3)
		end

		-------------------------------------------------------------- console
		local con = cf(0, 6.2, -3.75) * ang(-30, 0, 0)
		local function at(x, y, z) return con * CFrame.new(x, y, z) end
		B:block("Root", v(5.2, 1.0, 1.5), con, O2)
		B:block("Root", v(5.35, 0.22, 1.65), at(0, 0.52, 0), O3)
		B:block("Root", v(5.3, 0.2, 1.55), at(0, -0.56, 0), LD)
		B:block("Root", v(3.4, 0.86, 0.06), at(0, 0, 0.77), O1)
		B:block("Root", v(3.5, 0.1, 0.1), at(0, 0.47, 0.77), LA)
		B:block("Root", v(3.5, 0.1, 0.1), at(0, -0.47, 0.77), LA)
		-- heat gauge: red -> orange -> yellow bars
		local heat = { NR, NR, NR, NA, NA, NA, NA, NB, NB, NB }
		for i = 1, 10 do
			local hgt = 0.18 + (i - 1) * 0.05
			B:block("Root", v(0.22, hgt, 0.05), at(-1.44 + (i - 1) * 0.32, -0.36 + hgt / 2, 0.81), heat[i], N("Bar" .. i))
		end
		-- pressure gauges with swinging needles
		for _, sx in { 1, -1 } do
			local gx = sx * 2.1
			B:block("Root", v(0.7, 0.7, 0.08), at(gx, 0, 0.76), LD)
			B:block("Root", v(0.56, 0.56, 0.06), at(gx, 0, 0.8), "#f4e3c8")
			B:block("Root", v(0.14, 0.14, 0.06), at(gx + 0.17, 0.17, 0.82), NR, neon)
			local nb = B:bone(sx == 1 and "NeedleR" or "NeedleL", "Root", at(gx, -0.12, 0.84))
			B:block(nb, v(0.05, 0.36, 0.04), at(gx, 0.04, 0.85), O1)
			B:block("Root", v(0.1, 0.1, 0.06), at(gx, -0.12, 0.86), O1)
			B:block("Root", v(0.24, 1.15, 1.35), at(sx * 2.72, 0, 0), O3)
		end
		local lip = B:block("Root", v(3.0, 0.08, 0.16), at(0, -0.62, 0.72), NA, N("Lip"))

		-------------------------------------------------------------- volcano
		local vz = -4.0
		B:block("Root", v(3.4, 0.5, 2.0), cf(0, 7.0, vz), O2)
		B:block("Root", v(3.5, 0.12, 2.1), cf(0, 6.82, vz), LD)
		B:block("Root", v(2.6, 0.5, 1.6), cf(0.05, 7.5, vz), O3)
		B:block("Root", v(2.7, 0.1, 1.7), cf(0.05, 7.27, vz), LD)
		B:block("Root", v(1.9, 0.5, 1.25), cf(-0.05, 8.0, vz), O2)
		B:block("Root", v(0.5, 0.4, 0.5), cf(1.45, 7.4, vz + 0.6), O2)
		B:block("Root", v(0.6, 0.35, 0.5), cf(-1.4, 7.4, vz - 0.55), O3)
		B:block("Root", v(1.75, 0.5, 1.2), cf(0, 8.5, vz), O3)
		B:block("Root", v(1.85, 0.08, 1.3), cf(0, 8.27, vz), LD)
		for _, sz in { 1, -1 } do
			B:block("Root", v(0.4, 0.12, 0.3), cf(0.2, 8.77, vz + sz * 0.6), LC)
			B:block("Root", v(0.12, 0.5, 0.12), cf(0.2, 8.52, vz + sz * 0.62), LB)
			B:block("Root", v(0.06, 0.4, 0.06), cf(0.2, 8.52, vz + sz * 0.69), NB, neon)
		end
		-- crater rim around the lava pool
		B:block("Root", v(1.6, 0.3, 0.25), cf(0, 8.9, vz - 0.5), O1)
		B:block("Root", v(1.6, 0.3, 0.25), cf(0, 8.9, vz + 0.5), O1)
		B:block("Root", v(0.25, 0.3, 0.8), cf(-0.68, 8.9, vz), O1)
		B:block("Root", v(0.25, 0.3, 0.8), cf(0.68, 8.9, vz), O1)
		B:block("Root", v(1.15, 0.1, 0.78), cf(0, 8.83, vz), LC)
		local crater = B:block("Root", v(1.0, 0.06, 0.62), cf(0, 8.89, vz), NB, N("Crater"))
		-- lava streams down the cone, front and back (molten plastic + hot neon core)
		for _, sz in { 1, -1 } do
			local k = sz == 1 and "A" or "B"
			B:block("Root", v(0.42, 0.12, 0.34), cf(0.2, 8.27, vz + sz * 0.6), LB)
			B:block("Root", v(0.42, 0.12, 0.4), cf(0.25, 7.77, vz + sz * 0.8), LA)
			B:block("Root", v(0.42, 0.12, 0.4), cf(0.15, 7.27, vz + sz * 1.0), LA)
			B:block("Root", v(0.12, 0.5, 0.12), cf(0.25, 7.52, vz + sz * 0.9), LA)
			B:block("Root", v(0.12, 0.5, 0.12), cf(0.15, 7.02, vz + sz * 1.1), LD)
			B:block("Root", v(0.3, 0.06, 0.3), cf(0.2, 8.34, vz + sz * 0.62), NB, N("Stream" .. k .. "1"))
			B:block("Root", v(0.3, 0.06, 0.36), cf(0.25, 7.84, vz + sz * 0.82), NA, N("Stream" .. k .. "2"))
			B:block("Root", v(0.3, 0.06, 0.36), cf(0.15, 7.34, vz + sz * 1.02), NR, N("Stream" .. k .. "3"))
		end
		-- streams down the left/right faces of the cone too
		for _, sx in { 1, -1 } do
			B:block("Root", v(0.34, 0.12, 0.42), cf(sx * 0.8, 8.27, vz + 0.2 * sx), LB)
			B:block("Root", v(0.4, 0.12, 0.42), cf(sx * 1.15, 7.77, vz + 0.25 * sx), LA)
			B:block("Root", v(0.12, 0.5, 0.42), cf(sx * 1.32, 7.5, vz + 0.25 * sx), LA)
			B:block("Root", v(0.4, 0.12, 0.42), cf(sx * 1.55, 7.27, vz + 0.3 * sx), LA)
			B:block("Root", v(0.12, 0.5, 0.42), cf(sx * 1.73, 7.0, vz + 0.3 * sx), LD)
			B:block("Root", v(0.06, 0.4, 0.2), cf(sx * 1.39, 7.5, vz + 0.25 * sx), NA, neon)
		end
		-- console front face: molten crack pattern
		B:block("Root", v(1.8, 0.14, 0.06), at(-1.2, 0.1, -0.77), LA)
		B:block("Root", v(0.14, 0.5, 0.06), at(-0.36, -0.1, -0.77), LA)
		B:block("Root", v(1.4, 0.14, 0.06), at(0.3, -0.3, -0.77), LA)
		B:block("Root", v(0.14, 0.45, 0.06), at(0.95, -0.1, -0.77), LA)
		B:block("Root", v(1.2, 0.14, 0.06), at(1.5, 0.15, -0.77), LA)
		B:block("Root", v(1.3, 0.06, 0.04), at(-1.2, 0.1, -0.8), NB, N("FaceCrack1"))
		B:block("Root", v(1.0, 0.06, 0.04), at(0.3, -0.3, -0.8), NB, N("FaceCrack2"))
		B:block("Root", v(0.8, 0.06, 0.04), at(1.5, 0.15, -0.8), NB, N("FaceCrack3"))
		-- console top: glowing fissures
		B:block("Root", v(2.6, 0.06, 0.16), at(-0.4, 0.64, -0.2), LA)
		B:block("Root", v(0.16, 0.06, 0.9), at(0.85, 0.64, 0.05), LA)
		B:block("Root", v(1.4, 0.06, 0.16), at(1.5, 0.64, 0.45), LA)
		B:block("Root", v(1.8, 0.07, 0.06), at(-0.4, 0.66, -0.2), NB, N("Fissure"))
		-- side lava stream (left) for asymmetry
		B:block("Root", v(0.4, 0.12, 0.4), cf(-1.05, 7.77, vz - 0.1), LA)
		B:block("Root", v(0.4, 0.12, 0.4), cf(-1.45, 7.27, vz - 0.15), LD)

		-- orbiting lava rocks around the volcano (two rings, opposite ways)
		local orbit = B:bone("Orbit", "Root", v(0, 9.4, vz))
		for k = 0, 3 do
			local a = k * math.pi / 2
			local p = v(math.cos(a) * 1.9, 9.3 + (k % 2) * 0.25, vz + math.sin(a) * 1.9)
			B:block(orbit, v(0.5, 0.42, 0.5), CFrame.new(p) * ang(25, k * 30, 15), O2)
			B:block(orbit, v(0.3, 0.5, 0.3), CFrame.new(p) * ang(-20, k * 50, 35), O3)
			B:block(orbit, v(0.26, 0.26, 0.54), CFrame.new(p) * ang(0, k * 40, 0), LA)
			B:block(orbit, v(0.16, 0.16, 0.58), CFrame.new(p) * ang(0, k * 40, 0), NB, neon)
		end
		local orbit2 = B:bone("Orbit2", "Root", v(0, 7.6, vz))
		for k = 0, 2 do
			local a = k * math.pi * 2 / 3 + 0.5
			local p = v(math.cos(a) * 2.5, 7.6, vz + math.sin(a) * 2.5)
			B:block(orbit2, v(0.34, 0.3, 0.34), CFrame.new(p) * ang(30, k * 20, 20), O3)
			B:block(orbit2, v(0.2, 0.2, 0.42), CFrame.new(p) * ang(10, k * 70, 0), LB)
		end

		------------------------------------------------------------ handrails
		for _, s in { 1, -1 } do
			local x = s * 2.4
			B:bar("Root", v(x, 5.55, -3.45), v(x, 4.7, -0.5), 0.42, 0.42, O3)
			B:bar("Root", v(x, 5.3, -2.4), v(x, 4.9, -1.0), 0.54, 0.54, LD)
			B:block("Root", v(0.55, 0.5, 0.5), cf(x, 4.66, -0.45), O2)
			B:block("Root", v(0.3, 0.3, 0.1), cf(x, 4.66, -0.2), LB)
			B:block("Root", v(0.16, 0.16, 0.06), cf(x, 4.66, -0.14), NB, neon)
		end

		-------------------------------------------------------------- effects
		B:emitter(crater, "fire", { color = { NB, NA, NR }, rate = 14, size = { 0.9, 0.6, 0 }, speed = { 1.5, 3 }, name = "CraterFire" })
		B:emitter(crater, "smoke", { color = { "#3a2a2a", "#1a1414" }, rate = 3, size = { 1, 2.5, 3.5 }, speed = { 1.5, 2.5 }, name = "CraterSmoke" })
		B:emitter(crater, "burst", { color = { NB, NA, NR }, tex = "fire", size = { 0.6, 0.4, 0 }, speed = { 6, 11 }, accel = { 0, -14, 0 }, spread = 40, name = "Erupt" })
		B:light(crater, { color = "#ff7a1a", brightness = 1.0, range = 12, name = "CraterLight" })
		B:emitter(lip, "drip", { color = { NB, NA }, rate = 2, name = "LavaDrip" })
		for _, s in { 1, -1 } do
			local ep = B:block("Root", v(0.5, 0.1, 7.0), cf(s * 2.88, 1.35, 0), NA, { tr = 1, name = s == 1 and "EmberSrcR" or "EmberSrcL" })
			B:emitter(ep, "ember", { color = { NB, NA, NR }, rate = 4, size = { 0.25, 0.15, 0 }, speed = { 1, 2.2 }, name = s == 1 and "EmberR" or "EmberL" })
		end
		local vr = B:block("Root", v(0.5, 0.1, 0.5), CFrame.new(ventTops.R2), NA, { tr = 1, name = "VentSrcR" })
		local vl = B:block("Root", v(0.5, 0.1, 0.5), CFrame.new(ventTops.L2), NA, { tr = 1, name = "VentSrcL" })
		B:emitter(vr, "fire", { color = { NB, NA, NR }, rate = 5, size = { 0.6, 0.4, 0 }, speed = { 1, 2.5 }, name = "VentFireR" })
		B:emitter(vl, "fire", { color = { NB, NA, NR }, rate = 5, size = { 0.6, 0.4, 0 }, speed = { 1, 2.5 }, name = "VentFireL" })
		B:light(B:block("Root", v(0.2, 0.1, 0.2), cf(0, 1.6, 0.3), NA, { tr = 1, name = "BeltGlowSrc" }), { color = "#ff5a10", brightness = 0.6, range = 9, name = "BeltGlow" })
	end,
}
