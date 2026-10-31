--!nocheck
-- Savanna Signpost (Sandy Savanna decoration, medium, gently animated).
-- A sun-bleached wooden signpost wedged into a pile of layered sandstone
-- rocks on a small golden-sand patch with dry grass. Three arrow boards hang
-- by rope loops from short wooden arms (bones BoardA/B/C, pivot on the arm,
-- local +X along the arm) and swing gently in the wind. Faded painted icons
-- point the way: a sun, an oasis water drop and a cactus. The post is crowned
-- by a cow-horn decoration (no skull): a wooden plaque with a pair of
-- stepped cream horns tied with red cloth, and two little bead strings
-- (bones BeadL/BeadR) that sway.
return {
	DisplayName = "Savanna Signpost",
	Rarity = "Decor",
	Element = "Sandy Savanna",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		local SAND_DK, SAND_DK2, SAND, SAND_LT, SAND_TOP = "#c48a45", "#b77d3c", "#d9a95c", "#e8c27a", "#f0d08e"
		local ROCK, ROCK_DK, ROCK_LT = "#c9774a", "#a9573a", "#e0a06a"
		local GRASS, GRASS_DK, GRASS_LT = "#d9b84a", "#b8963a", "#f0d872"
		local PEBBLE, PEBBLE_DK = "#bfae94", "#968670"
		local WOOD, WOOD_DK, WOOD_LT, WOOD_GR = "#dcc296", "#ab8d66", "#f0e0bc", "#cbb187"
		local CRACK, NAIL = "#7d6448", "#5c5650"
		local BOARD, BOARD_DK, BOARD_LT = "#ead2a0", "#b8925e", "#f7e8c6"
		local ROPE, ROPE_DK = "#c9a066", "#a57d48"
		local HORN, HORN_MID, HORN_TIP = "#f6ecd4", "#e2cc9e", "#5a4636"
		local CLOTH, CLOTH_DK = "#d2452f", "#a3301f"
		local TURQ, BEAD_Y = "#38bdb0", "#ffc83c"
		local INK = "#7a5636"
		local SUN, SUN_DK = "#ffb43a", "#f07a28"
		local WATER, WATER_LT = "#3aa8e0", "#8fd8ff"
		local CAC, CAC_DK = "#5aa848", "#3f7d35"

		local seed = 2171
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end
		local function pick(t)
			return t[math.floor(rnd(1, #t + 0.999))]
		end

		------------------------------------------------------------ sand footing
		B:block(R, v(6.4, 0.4, 4.4), cf(0, 0.2, 0), SAND_DK)
		B:block(R, v(4.4, 0.38, 6.0), cf(0.1, 0.19, 0.1), SAND_DK)
		B:block(R, v(5.6, 0.36, 5.2), cf(-0.1, 0.18, 0, 0, 14, 0), SAND_DK2)
		for i = 0, 7 do
			local a = (i + rnd(-0.25, 0.25)) / 8 * 360
			local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0, -(2.9 + rnd(-0.2, 0.3)))
			local h = rnd(0.3, 0.46)
			B:block(R, v(rnd(1.3, 1.9), h, rnd(1.0, 1.3)), CFrame.new(p.Position.X, h / 2, p.Position.Z) * ang(0, a + rnd(-8, 8), 0), pick({ SAND_DK, SAND_DK2, SAND }))
		end
		B:block(R, v(4.4, 0.3, 3.6), cf(0, 0.52, 0, 0, -10, 0), SAND)
		B:block(R, v(1.4, 0.12, 0.9), cf(1.7, 0.43, -1.6, 0, 25, 0), SAND_TOP)

		-- rock pile wedging the post
		local function rock(x, z, y, s, yaw, top)
			local c = CFrame.new(x, y, z) * ang(0, yaw, 0)
			B:block(R, v(1.6 * s, 0.28 * s, 1.3 * s), c * CFrame.new(0, 0.14 * s, 0), ROCK_DK)
			B:block(R, v(1.4 * s, 0.75 * s, 1.15 * s), c * CFrame.new(0, 0.6 * s, 0), ROCK)
			if top ~= false then
				B:block(R, v(1.0 * s, 0.45 * s, 0.85 * s), c * CFrame.new(0.12 * s, 1.15 * s, -0.04 * s) * ang(0, 14, 0), ROCK_LT)
			end
		end
		rock(-1.25, -0.5, 0.5, 1.0, 20)
		rock(1.2, 0.6, 0.5, 0.95, -15)
		rock(0.3, -1.35, 0.5, 0.7, 40)
		rock(-0.6, 1.4, 0.5, 0.75, -30, false)
		rock(2.3, -1.2, 0.3, 0.55, 10)
		-- pebbles
		B:block(R, v(0.5, 0.36, 0.45), cf(-2.4, 0.55, -1.2, 0, 30, 0), PEBBLE)
		B:block(R, v(0.42, 0.32, 0.42), cf(2.5, 0.5, 1.4, 0, 10, 0), PEBBLE_DK)
		B:block(R, v(0.46, 0.3, 0.4), cf(-1.8, 0.5, 2.1, 0, 50, 0), PEBBLE)

		-- dry grass tufts
		local function tuft(x, z, y, s)
			s = s or 1
			local base = CFrame.new(x, y, z) * ang(0, rnd(0, 90), 0)
			B:block(R, v(0.3, 1.4 * s, 0.3), base * CFrame.new(0, 0.6 * s, 0), GRASS)
			B:block(R, v(0.28, 1.15 * s, 0.28), base * CFrame.new(0.3, 0.45 * s, 0) * ang(0, 0, -25), GRASS_LT)
			B:block(R, v(0.28, 1.0 * s, 0.28), base * CFrame.new(-0.28, 0.4 * s, 0.05) * ang(0, 0, 25), GRASS_DK)
			B:block(R, v(0.26, 0.9 * s, 0.26), base * CFrame.new(0, 0.36 * s, 0.28) * ang(25, 0, 0), GRASS)
		end
		tuft(-2.2, 0.4, 0.4, 1.1)
		tuft(2.0, -0.2, 0.55, 1.0)
		tuft(0.9, 2.2, 0.4, 0.85)
		tuft(-1.0, -2.2, 0.4, 0.8)
		tuft(1.5, -2.3, 0.35, 0.7)

		------------------------------------------------------------ post
		local PW, PTOP = 1.3, 10.0
		B:block(R, v(PW, PTOP - 0.3, PW), cf(0, (PTOP - 0.3) / 2 + 0.3, 0), WOOD)
		-- weathered grain strips on the faces
		for _, g in { { -0.32, 3.2, 2.4, WOOD_DK }, { 0.28, 6.6, 3.0, WOOD_LT }, { -0.1, 8.6, 1.6, WOOD_GR }, { 0.35, 2.0, 1.6, WOOD_GR } } do
			B:block(R, v(0.16, g[3], 0.1), cf(g[1], g[2], -PW / 2 - 0.03), g[4])
			B:block(R, v(0.16, g[3] * 0.8, 0.1), cf(-g[1], g[2] + 0.6, PW / 2 + 0.03), g[4])
			B:block(R, v(0.1, g[3] * 0.9, 0.16), cf(PW / 2 + 0.03, g[2] - 0.4, g[1]), g[4])
			B:block(R, v(0.1, g[3] * 0.7, 0.16), cf(-PW / 2 - 0.03, g[2] + 0.3, -g[1]), g[4])
		end
		-- a dark crack + knot
		B:block(R, v(0.12, 1.1, 0.1), cf(0.15, 4.9, -PW / 2 - 0.04, 0, 0, 8), CRACK)
		B:block(R, v(0.34, 0.34, 0.1), cf(-0.25, 5.6, -PW / 2 - 0.04), WOOD_DK)
		-- stepped cap
		B:block(R, v(PW + 0.3, 0.35, PW + 0.3), cf(0, PTOP + 0.12, 0), WOOD_DK)
		B:block(R, v(PW - 0.2, 0.3, PW - 0.2), cf(0, PTOP + 0.44, 0), WOOD)
		B:block(R, v(0.5, 0.25, 0.5), cf(0, PTOP + 0.7, 0), WOOD_LT)

		------------------------------------------------------------ arrow boards
		-- arm + hanging board in a frame F at the arm (local +X outward)
		local function board(name, yaw, yArm, x0, L, H, trim, paint)
			local F = CFrame.new(0, yArm, 0) * ang(0, yaw, 0)
			-- arm (static) with a peg cap at the tip
			B:block(R, v(x0 + L - 0.3, 0.4, 0.42), F * CFrame.new((x0 + L - 0.3) / 2, 0, 0), WOOD_GR)
			B:block(R, v(0.3, 0.56, 0.56), F * CFrame.new(x0 + L - 0.3, 0, 0), WOOD_DK)
			B:block(R, v(0.22, 0.22, 0.12), F * CFrame.new(0.05, 0, -0.68), NAIL)
			local bone = B:bone(name, "Root", F)
			local top = -0.55
			local cy = top - H / 2
			local x1 = x0 + 0.35
			local len = L - H * 0.5
			-- rope loops
			for _, rx in { x1 + 0.5, x1 + len - 0.6 } do
				B:block(bone, v(0.18, 0.75, 0.18), F * CFrame.new(rx, -0.25, -0.05), ROPE)
				B:block(bone, v(0.18, 0.75, 0.18), F * CFrame.new(rx, -0.25, 0.05) * ang(0, 0, 12), ROPE_DK)
				B:block(bone, v(0.22, 0.22, 0.12), F * CFrame.new(rx, top - 0.22, -0.24), NAIL)
			end
			-- board + arrow tip (a 45-degree square half buried in the board end)
			B:block(bone, v(len, H, 0.36), F * CFrame.new(x1 + len / 2, cy, 0), BOARD)
			local d = H / math.sqrt(2)
			B:block(bone, v(d, d, 0.34), F * CFrame.new(x1 + len, cy, 0) * ang(0, 0, 45), BOARD)
			-- tail notch: two lighter fletch blocks at the inner end
			B:block(bone, v(0.3, H + 0.2, 0.4), F * CFrame.new(x1 + 0.15, cy, 0), BOARD_DK)
			-- weathered trim stripes along the top + bottom edge (both faces)
			for _, zz in { -0.2, 0.2 } do
				B:block(bone, v(len - 0.4, 0.14, 0.06), F * CFrame.new(x1 + len / 2 + 0.1, cy + H / 2 - 0.16, zz), trim)
				B:block(bone, v(len - 0.6, 0.14, 0.06), F * CFrame.new(x1 + len / 2, cy - H / 2 + 0.16, zz), trim)
			end
			-- faded "writing" dashes on both faces
			for _, zz in { -0.2, 0.2 } do
				local xs = x1 + 1.75
				for k = 0, 2 do
					local wdash = ({ 0.55, 0.35, 0.5 })[k + 1]
					B:block(bone, v(wdash, 0.18, 0.06), F * CFrame.new(xs + k * 0.7 + wdash / 2, cy + 0.12, zz), INK)
				end
				B:block(bone, v(1.3, 0.14, 0.06), F * CFrame.new(xs + 0.65, cy - 0.22, zz), INK)
			end
			-- painted icon near the inner end, both faces
			for _, zz in { -0.21, 0.21 } do
				local ic = F * CFrame.new(x1 + 1.0, cy, zz) * CFrame.new() 
				paint(bone, ic, zz < 0 and -1 or 1)
			end
			-- a crack on the front
			B:block(bone, v(0.5, 0.08, 0.06), F * CFrame.new(x1 + len - 0.6, cy - 0.1, -0.21) * ang(0, 0, 20), CRACK)
			return bone
		end

		local function paintSun(bone, c, s)
			B:block(bone, v(0.6, 0.6, 0.05), c, SUN)
			B:block(bone, v(0.5, 0.5, 0.06), c * ang(0, 0, 45), SUN_DK)
			B:block(bone, v(0.36, 0.36, 0.08), c, BEAD_Y)
		end
		local function paintDrop(bone, c, s)
			B:block(bone, v(0.56, 0.4, 0.05), c * CFrame.new(0, -0.12, 0), WATER)
			B:block(bone, v(0.36, 0.3, 0.05), c * CFrame.new(0, 0.2, 0), WATER)
			B:block(bone, v(0.16, 0.2, 0.06), c * CFrame.new(0, 0.42, 0), WATER)
			B:block(bone, v(0.14, 0.18, 0.07), c * CFrame.new(-0.12, -0.08, 0), WATER_LT)
		end
		local function paintCactus(bone, c, s)
			B:block(bone, v(0.22, 0.7, 0.05), c, CAC)
			B:block(bone, v(0.16, 0.36, 0.05), c * CFrame.new(-0.24, 0.08, 0), CAC)
			B:block(bone, v(0.16, 0.3, 0.05), c * CFrame.new(0.24, 0.16, 0), CAC)
			B:block(bone, v(0.6, 0.1, 0.06), c * CFrame.new(0, -0.08, 0), CAC_DK)
		end

		board("BoardA", 0, 8.5, 0.3, 4.6, 1.5, "#e0784a", paintSun)
		board("BoardB", 180, 6.6, 0.3, 4.3, 1.4, "#58b4b0", paintDrop)
		board("BoardC", -38, 4.7, 0.6, 3.6, 1.3, "#8cbc5a", paintCactus)

		------------------------------------------------------------ cow-horn crown
		local HY = 9.35
		-- wooden plaque on the post front
		B:block(R, v(2.0, 1.25, 0.36), cf(0, HY - 0.25, -PW / 2 - 0.16), WOOD_DK)
		B:block(R, v(1.6, 0.9, 0.12), cf(0, HY - 0.25, -PW / 2 - 0.38), WOOD_LT)
		B:block(R, v(0.5, 0.5, 0.1), cf(0, HY - 0.25, -PW / 2 - 0.47, 0, 0, 45), CLOTH)
		B:block(R, v(0.24, 0.24, 0.1), cf(0, HY - 0.25, -PW / 2 - 0.54), BEAD_Y)
		-- horn pair: stepped bars curving out and up, cream -> tan -> dark tip
		B:sym(function(side)
			local sx = 1 -- B:sym mirrors automatically
			local pts = {
				v(0.3 * sx, HY + 0.5, -0.15),
				v(1.6 * sx, HY + 0.6, -0.25),
				v(2.6 * sx, HY + 1.05, -0.3),
				v(3.15 * sx, HY + 1.85, -0.3),
				v(3.25 * sx, HY + 2.6, -0.25),
			}
			local ws = { 0.85, 0.7, 0.55, 0.42 }
			local cols = { HORN, HORN, HORN_MID, HORN_TIP }
			for i = 1, 4 do
				local a, b = pts[i], pts[i + 1]
				local dir = (b - a).Unit
				B:bar(R, a - dir * 0.15, b + dir * 0.15, ws[i], ws[i], cols[i])
			end
			-- cloth wrap at the horn base
			B:block(R, v(0.4, 1.05, 1.05), cf(1.05 * sx, HY + 0.55, -0.2), CLOTH)
			B:block(R, v(0.18, 1.1, 1.1), cf(1.25 * sx, HY + 0.55, -0.2), CLOTH_DK)
			-- bead string hanging below the horn base (bone sways)
			local bead = B:bone("Bead" .. side, "Root", v(1.25 * sx, HY + 0.1, -0.85))
			B:block(bead, v(0.1, 1.0, 0.1), cf(1.25 * sx, HY - 0.35, -0.85), ROPE_DK)
			B:block(bead, v(0.3, 0.3, 0.3), cf(1.25 * sx, HY - 0.3, -0.85, 0, 45, 0), TURQ)
			B:block(bead, v(0.28, 0.28, 0.28), cf(1.25 * sx, HY - 0.68, -0.85, 0, 45, 0), CLOTH)
			B:block(bead, v(0.32, 0.32, 0.32), cf(1.25 * sx, HY - 1.06, -0.85, 0, 45, 0), BEAD_Y)
			B:block(bead, v(0.2, 0.36, 0.1), cf(1.25 * sx, HY - 1.38, -0.85), TURQ)
		end)
	end,
}
