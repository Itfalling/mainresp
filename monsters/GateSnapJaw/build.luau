--!nocheck
-- Snap-Jaw Jungle Gate (Map landmark, stage 5 gate). A carnivorous-bog arch
-- spanning the whole 64-stud run lane: a colossal Venus flytrap head gapes at the
-- approaching player, its jaws hinged on two mossy carved stone totems.
-- * Totems (x = +-32..44): stepped plinth, three stacked carved stone heads with
--   neon-lime eyes and cream flytrap-tooth grins (carved on both faces), moss caps
--   and drips, climbing vines, a stepped capital.
-- * Jaws: an arched upper lobe and a sagging lower lobe meet at the totems. Green
--   outer hide, crimson rims, cream interlocking teeth, long trigger cilia
--   radiating from the upper lobe like a crown. The mouth is filled with a
--   pink inner lobe (green on the back) with darker vein spots and a lime seam.
-- * The plain cream "Sign" sits in the mouth in a chunky mossy stone frame (the
--   map tool adds the stage name on its -Z face).
-- * Glowing pitcher pods (lime neon nectar) crown both totems and sit on the jaw
--   shoulders; big jungle leaves fan out from the hinges; vine strands hang.
-- Opening: completely clear for |x| < 32, y < 19 (lowest part: lower jaw 19.3).
-- Static Filler landmark: no scripts, no effects.
return {
	DisplayName = "Snap-Jaw Jungle Gate",
	Rarity = "Landmark",
	Filler = true,
	Element = "Snap-Jaw Jungle",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local R = "Root"

		local STONE, STONE_LT, STONE_DK, STONE_XDK = "#9a9180", "#b8ae98", "#757062", "#4e4a40"
		local MOSS, MOSS_DK, MOSS_LT = "#6cb337", "#4f8f2a", "#9fd84a"
		local GREEN, GREEN_DK, GREEN_LT, GREEN_TOP = "#3caa3c", "#1f6e2a", "#9fd84a", "#58c447"
		local INSIDE, INSIDE_DK, RIM, THROAT = "#ff5c7c", "#b02448", "#c92a48", "#5c0f25"
		local CREAM, CREAM_DK = "#fff4d2", "#e8d9b0"
		local LIME = "#a6ff3c"
		local VINE, VINE_DK = "#2f8a2c", "#1f6e2a"
		local LEAF, LEAF_DK, LEAF_LT = "#36b04a", "#1f7f34", "#62cf5a"
		local HOOD = "#ff6d8a"
		local SIGN = "#fff6dc"

		local seed = 905
		local function rnd(a, b)
			seed = (seed * 1103515245 + 12345) % 2147483648
			return a + (b - a) * (seed / 2147483648)
		end

		local PX = 38
		local HX = 31.5 -- jaw hinge |x|
		local HY = 24.2 -- jaw hinge y
		local function yU(x) -- upper jaw centreline
			local k = math.clamp(x / HX, -1, 1)
			return HY + 5.2 * (1 - k * k)
		end
		local function yL(x) -- lower jaw centreline
			local k = math.clamp(x / HX, -1, 1)
			return HY - 3.7 * (1 - k * k)
		end

		---------------------------------------------------------------- carved face helper
		local function face(x, y, fz, f, w, big)
			-- brow
			B:block(R, v(w * 0.8, 0.8, 0.5), cf(x, y + 1.6, fz), STONE_LT)
			-- eyes: dark socket + lime glow
			for _, ex in { -1, 1 } do
				B:block(R, v(1.6, 1.4, 0.4), cf(x + ex * w * 0.22, y + 0.6, fz + f * 0.05), STONE_XDK)
				B:block(R, v(0.9, 0.8, 0.42), cf(x + ex * w * 0.22, y + 0.6, fz + f * 0.1), LIME, { mat = "Neon" })
			end
			-- jaw mouth with flytrap teeth
			local mw = w * (big and 0.78 or 0.66)
			B:block(R, v(mw, 1.6, 0.4), cf(x, y - 1.2, fz + f * 0.05), THROAT)
			B:block(R, v(mw + 0.6, 0.4, 0.5), cf(x, y - 0.25, fz + f * 0.05), RIM)
			B:block(R, v(mw + 0.6, 0.4, 0.5), cf(x, y - 2.15, fz + f * 0.05), RIM)
			if big then
				for i = 0, 4 do
					local tx = x - mw / 2 + (i + 0.5) * mw / 5
					B:block(R, v(0.5, 0.9, 0.3), cf(tx, y - 0.75, fz + f * 0.15), CREAM)
					B:block(R, v(0.5, 0.8, 0.3), cf(tx + mw / 10, y - 1.7, fz + f * 0.15), CREAM_DK)
				end
			else
				B:block(R, v(mw - 0.4, 0.7, 0.3), cf(x, y - 0.75, fz + f * 0.15), CREAM)
			end
		end

		---------------------------------------------------------------- totems
		B:sym(function(side, s)
			-- plinth
			B:block(R, v(12, 1.4, 10.4), cf(PX, 0.7, 0), STONE_DK)
			B:block(R, v(11, 1.0, 9.6), cf(PX, 1.9, 0), STONE)
			-- three stacked carved heads
			local heads = { { 2.4, 9.0, 9.4, 8.2 }, { 9.0, 15.6, 9.0, 7.8 }, { 15.6, 23.0, 10.2, 8.6 } }
			for i, h in heads do
				local y0, y1, w, d = h[1], h[2], h[3], h[4]
				local yc = (y0 + y1) / 2
				B:block(R, v(w, y1 - y0, d), cf(PX, yc, 0, 0, (i == 2) and 4 or 0, 0), (i == 2) and STONE_LT or STONE)
				-- dark band between heads
				B:block(R, v(w + 0.3, 0.5, d + 0.3), cf(PX, y0 + 0.25, 0), STONE_XDK)
				-- cheek blocks (side ears)
				B:block(R, v(0.8, 2.6, 3.0), cf(PX - w / 2 - 0.3, yc, 0), STONE_DK)
				B:block(R, v(0.8, 2.6, 3.0), cf(PX + w / 2 + 0.3, yc, 0), STONE_DK)
				for _, f in { -1, 1 } do
					face(PX, yc + 0.2, f * (d / 2 + 0.2), f, w, i == 3)
				end
				-- moss cap with drips
				B:block(R, v(w + 0.2, 0.5, d + 0.2), cf(PX + 0.2, y1 - 0.1, 0), MOSS)
				for k = 1, 3 do
					local dx = rnd(-w * 0.4, w * 0.4)
					local f = (k % 2 == 0) and 1 or -1
					B:block(R, v(0.8, rnd(0.8, 1.8), 0.4), cf(PX + dx, y1 - 0.9, f * (d / 2 + 0.15)), (k == 2) and MOSS_LT or MOSS_DK)
				end
			end
			-- capital
			B:block(R, v(11.6, 1.4, 9.8), cf(PX, 23.7, 0), STONE_DK)
			B:block(R, v(10.6, 1.0, 9.0), cf(PX, 24.9, 0), STONE)
			B:block(R, v(11.0, 0.5, 9.4), cf(PX + 0.3, 25.6, 0), MOSS)
			-- climbing vine on the outer face + front/back
			local prev
			for i = 0, 12 do
				local t = i / 12
				local a = t * math.pi * 2.4 - 0.6
				local p = v(PX + math.cos(a) * 5.4, 1.5 + t * 22.5, math.sin(a) * 4.7)
				if p.X < 32.4 then
					p = v(32.4, p.Y, p.Z)
				end
				if prev then
					B:bar(R, prev, p, 0.6, 0.6, (i % 2 == 0) and VINE or VINE_DK)
				end
				if i % 3 == 0 and i > 0 and p.X > 33.5 then
					B:block(R, v(1.4, 0.3, 1.0), CFrame.new(p) * ang(rnd(-30, 30), math.deg(a), 25), LEAF_LT)
				end
				prev = p
			end
		end)

		---------------------------------------------------------------- pitcher pods
		local function pitcher(pos, k, ry)
			local c = CFrame.new(pos) * ang(0, ry or 0, 0)
			B:block(R, v(2.6 * k, 1.4 * k, 2.6 * k), c * CFrame.new(0, 0.7 * k, 0), GREEN_DK)
			B:block(R, v(3.0 * k, 2.6 * k, 3.0 * k), c * CFrame.new(0, 2.6 * k, 0), GREEN)
			B:block(R, v(2.6 * k, 2.2 * k, 2.6 * k), c * CFrame.new(0, 4.8 * k, 0), GREEN_LT)
			-- red stripes
			for _, sx in { -1, 1 } do
				B:block(R, v(0.4 * k, 3.6 * k, 3.1 * k), c * CFrame.new(sx * 0.7 * k, 3.4 * k, 0), RIM)
			end
			-- rim + glowing nectar
			B:block(R, v(3.3 * k, 0.6 * k, 3.3 * k), c * CFrame.new(0, 6.1 * k, 0), HOOD)
			B:block(R, v(2.4 * k, 0.3 * k, 2.4 * k), c * CFrame.new(0, 6.35 * k, 0), LIME, { mat = "Neon" })
			-- hood lid leaning back
			B:block(R, v(2.8 * k, 0.4 * k, 2.2 * k), c * CFrame.new(0, 6.95 * k, 1.5 * k) * ang(-35, 0, 0), GREEN_TOP)
			B:block(R, v(2.0 * k, 0.45 * k, 1.4 * k), c * CFrame.new(0, 6.97 * k, 1.42 * k) * ang(-35, 0, 0), RIM)
		end
		B:sym(function()
			pitcher(v(PX + 0.6, 25.8, 0.4), 1.0, 0)
			-- big jungle leaves fanning from the hinge
			local leaves = {
				{ v(41.5, 27.0, -2.5), 30, -35, 5.0, LEAF }, { v(42.5, 27.4, 2.6), -25, -45, 4.6, LEAF_DK },
				{ v(35.0, 27.8, -3.2), 50, 20, 4.0, LEAF_LT }, { v(36.0, 27.6, 3.4), -45, 25, 4.2, LEAF },
				{ v(43.5, 25.8, 0.0), 0, -70, 4.4, LEAF_LT },
			}
			for _, l in leaves do
				local c = CFrame.new(l[1]) * ang(0, l[2], l[3])
				B:block(R, v(l[4], 0.35, 2.2), c, l[5])
				B:block(R, v(l[4] * 0.6, 0.4, 3.0), c * CFrame.new(l[4] * 0.1, 0, 0), l[5])
				B:block(R, v(l[4] * 0.9, 0.45, 0.3), c, GREEN_DK)
			end
		end)

		---------------------------------------------------------------- jaws
		local NJ = 9
		local function jawPoint(x, upper)
			return v(x, upper and yU(x) or yL(x), 0)
		end
		B:sym(function(side, s)
			for i = 0, NJ - 1 do
				local x0 = HX * (1 - i / NJ) + 0.6
				local x1 = HX * (1 - (i + 1) / NJ) - 0.4
				-- upper lobe: green outer hide (top) + crimson rim + pink lip
				local a, b = jawPoint(x0, true), jawPoint(x1, true)
				B:bar(R, a + v(0, 1.2, 0), b + v(0, 1.2, 0), 4.4, 2.9, (i % 2 == 0) and GREEN or GREEN_DK)
				B:bar(R, a + v(0, 2.7, 0), b + v(0, 2.7, 0), 3.4, 0.6, GREEN_TOP)
				B:bar(R, a + v(0, -0.5, 0), b + v(0, -0.5, 0), 4.2, 0.9, RIM)
				-- lower lobe
				local c, d = jawPoint(x0, false), jawPoint(x1, false)
				B:bar(R, c + v(0, -0.2, 0), d + v(0, -0.2, 0), 4.0, 2.0, (i % 2 == 0) and GREEN or GREEN_DK)
				B:bar(R, c + v(0, 0.95, 0), d + v(0, 0.95, 0), 4.2, 0.8, RIM)
			end
			-- teeth along both rims (interlocking), cream
			for i = 0, 10 do
				local x = 2.0 + i * 2.75
				local yu = yU(x) - 1.0
				local yl = yL(x) + 1.4
				local slopeU = math.deg(math.atan(-2 * 5.2 * x / (HX * HX)))
				local slopeL = math.deg(math.atan(2 * 3.7 * x / (HX * HX)))
				B:block(R, v(0.9, 2.4, 0.9), cf(x, yu - 0.9, -0.9, 0, 0, slopeU), (i % 2 == 0) and CREAM or CREAM_DK)
				B:block(R, v(0.9, 2.2, 0.9), cf(x + 1.35, yl + 0.8, -0.9, 0, 0, slopeL), (i % 2 == 0) and CREAM_DK or CREAM)
				-- back row of teeth too
				B:block(R, v(0.7, 1.6, 0.7), cf(x + 0.7, yu - 0.6, 0.9, 0, 0, slopeU), CREAM)
			end
			-- trigger cilia radiating from the upper lobe (crown of spikes)
			for i = 0, 10 do
				local x = 2.0 + i * 2.75
				local y = yU(x) + 2.6
				local nx = 2 * 5.2 * x / (HX * HX)
				local n = v(nx, 1, 0).Unit
				local len = 1.6 - i * 0.04
				local tip = v(x, y, 0) + n * len
				B:bar(R, v(x, y - 0.3, 0), tip, 0.75, 0.75, GREEN_DK, { up = v(0, 0, 1) })
				B:block(R, v(0.65, 0.65, 0.65), CFrame.new(tip) * ang(0, 45, 0), (i % 2 == 0) and CREAM or HOOD)
			end
			-- hinge knuckle bound to the totem
			B:block(R, v(3.4, 5.2, 4.6), cf(HX + 0.9, HY + 0.6, 0, 0, 0, 10), GREEN_DK)
			B:block(R, v(2.4, 3.4, 4.8), cf(HX + 0.6, HY + 0.6, 0), GREEN)
			B:block(R, v(0.8, 1.6, 4.9), cf(HX - 0.3, HY + 0.4, 0), RIM)
			-- small pitcher pods on the upper jaw shoulders
			pitcher(v(21.5, yU(21.5) + 2.3, 0.3), 0.55, 15)
			-- vine strands hanging from the lower jaw
			for _, hx in { 26.5, 18.0 } do
				local top = yL(hx) - 1.0
				local bot = math.max(top - 2.4, 19.6)
				B:block(R, v(0.35, top - bot, 0.35), cf(hx, (top + bot) / 2, 0.8), VINE_DK)
				B:block(R, v(1.2, 0.3, 0.8), cf(hx + 0.3, bot + 0.3, 0.8, 0, 0, 25), LEAF_LT)
			end
		end)
		-- upper jaw apex + lower jaw centre caps (fill the seam between halves)
		B:block(R, v(3.0, 3.0, 4.4), cf(0, yU(0) + 1.2, 0), GREEN)
		B:block(R, v(2.6, 0.6, 3.4), cf(0, yU(0) + 2.7, 0), GREEN_TOP)
		B:block(R, v(3.0, 2.0, 4.0), cf(0, yL(0) - 0.2, 0), GREEN)
		-- central apex cilia (tallest)
		B:bar(R, v(0, yU(0) + 2.6, 0), v(0, yU(0) + 4.0, 0), 0.75, 0.75, GREEN_DK, { up = v(0, 0, 1) })
		B:block(R, v(0.7, 0.7, 0.7), cf(0, yU(0) + 4.1, 0, 0, 45, 0), HOOD)

		---------------------------------------------------------------- mouth: inner lobe panel
		for x = -29, 29, 4 do
			local xa = math.abs(x)
			local top = yU(xa + (x >= 0 and 2 or -2) * 0) - 0.6
			local bot = yL(xa) + 0.6
			local hgt = math.max(0.5, top - bot)
			local mid = (top + bot) / 2
			B:block(R, v(4.05, hgt, 0.6), cf(x, mid, 0.2), (math.floor(x / 4) % 2 == 0) and INSIDE or "#ff6f8b")
			B:block(R, v(4.05, hgt, 0.6), cf(x, mid, 0.85), (math.floor(x / 4) % 2 == 0) and GREEN or GREEN_DK)
		end
		-- vein spots on the inner lobe (front), visible around the sign
		for _, sp in { { -22, 24.5 }, { -18, 26.6 }, { 19.5, 25.2 }, { 24, 23.6 }, { -26, 23.4 }, { 17, 27.4 } } do
			B:block(R, v(1.2, 1.2, 0.3), cf(sp[1], sp[2], -0.15, 0, 0, 45), INSIDE_DK)
		end
		-- lime seam glow in the throat (left/right of the sign)
		B:sym(function()
			B:block(R, v(10, 0.35, 0.3), cf(22.0, HY + 0.2, -0.2), LIME, { mat = "Neon" })
		end)
		-- back of the head: vein lines
		for _, x in { -20, -10, 10, 20 } do
			B:block(R, v(0.4, 4.0, 0.3), cf(x, 25.5, 1.25), GREEN_LT)
		end

		---------------------------------------------------------------- sign
		local SY = 23.6
		local SZ = -2.6
		B:block(R, v(28, 5.5, 1), cf(0, SY, SZ), SIGN, { name = "Sign" })
		B:block(R, v(27, 5, 1.6), cf(0, SY, SZ + 1.2), STONE_XDK)
		local FZ = SZ - 0.2
		B:block(R, v(31, 1.4, 1.8), cf(0, SY + 3.45, FZ), STONE)
		B:block(R, v(31, 1.4, 1.8), cf(0, SY - 3.45, FZ), STONE_DK)
		B:block(R, v(1.6, 5.6, 1.8), cf(-14.8, SY, FZ), STONE)
		B:block(R, v(1.6, 5.6, 1.8), cf(14.8, SY, FZ), STONE)
		for _, x in { -14.8, 14.8 } do
			for _, y in { SY + 3.45, SY - 3.45 } do
				B:block(R, v(2.1, 1.9, 2.1), cf(x, y, FZ), STONE_LT)
				B:block(R, v(0.8, 0.8, 0.3), cf(x, y, FZ - 1.1, 0, 0, 45), LIME, { mat = "Neon" })
			end
		end
		-- moss on the frame
		B:block(R, v(12, 0.5, 1.8), cf(-6.0, SY + 4.35, FZ), MOSS)
		B:block(R, v(6, 0.5, 1.6), cf(9.5, SY + 4.35, FZ), MOSS_LT)
		B:block(R, v(0.8, 1.6, 0.4), cf(-9.0, SY + 2.9, FZ - 0.95), MOSS_DK)
		B:block(R, v(0.8, 1.0, 0.4), cf(6.0, SY + 3.2, FZ - 0.95), MOSS)
	end,
}
