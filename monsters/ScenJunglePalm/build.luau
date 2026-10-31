--!nocheck
-- Jungle Palm Cluster (Snap-Jaw Jungle scenery, big copy-paste filler).
-- Three leaning jungle palms of different heights growing from one low bog
-- dirt patch:
-- * banded root-brown trunks (alternating tones, dark growth rings, a
--   flared root foot) that bow outward as they rise
-- * a dark crown knot with a few brown nuts under it
-- * big arching fronds: each segment is two leaflet plates folded down from
--   a lime midrib (gable shape), drooping toward the tip; upper fronds are
--   lighter, lower fronds darker
-- * moss pads, stones, grass tufts and two small ferns on the footing
-- Anchored, weld-free, no scripts or effects.
return {
	DisplayName = "Jungle Palm Cluster",
	Rarity = "Scenery",
	Filler = true,
	Element = "Snap-Jaw Jungle",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad
		local R = "Root"

		-- palette (Snap-Jaw Jungle crops + decorations)
		local DIRT_DK, DIRT_DK2, DIRT = "#3f2516", "#4d2d1a", "#6a4126"
		local MOSS, MOSS_DK = "#6cb337", "#4f8f2a"
		local GRASS, GRASS_DK = "#5fcf3c", "#3fa82e"
		local STONE, STONE_LT, STONE_DK = "#8d8174", "#a39787", "#6c6359"
		local GREEN, GREEN_DK, GREEN_LT, GREEN_TOP = "#3caa3c", "#1f6e2a", "#9fd84a", "#58c447"
		local ROOT, ROOT_DK, ROOT_LT = "#8b5a31", "#5a361d", "#a87244"

		------------------------------------------------------------ footing
		B:block(R, v(10.4, 0.3, 7.0), cf(0, 0.15, 0.2), DIRT_DK)
		B:block(R, v(7.0, 0.29, 10.4), cf(0, 0.145, 0.2), DIRT_DK)
		B:block(R, v(8.6, 0.28, 8.6), cf(0, 0.14, 0.2, 0, 45, 0), DIRT_DK2)
		B:block(R, v(4.6, 0.2, 3.2), cf(-0.6, 0.36, 0.6, 0, 20, 0), DIRT)
		for _, e in { { 20, 5.0, DIRT_DK2 }, { 110, 5.2, DIRT_DK }, { 200, 4.9, DIRT }, { 290, 5.1, DIRT_DK2 } } do
			local a = rad(e[1])
			B:block(R, v(1.8, 0.34, 1.0), CFrame.new(math.sin(a) * e[2], 0.17, 0.2 - math.cos(a) * e[2]) * CFrame.Angles(0, -a + rad(10), 0), e[3])
		end
		B:block(R, v(3.0, 0.2, 2.0), cf(2.2, 0.38, 2.0, 0, -15, 0), MOSS)
		B:block(R, v(2.2, 0.2, 1.6), cf(-2.6, 0.37, -1.6, 0, 25, 0), MOSS_DK)
		B:block(R, v(1.6, 0.2, 1.4), cf(-1.4, 0.39, 3.0, 0, 10, 0), MOSS)
		B:block(R, v(1.4, 0.9, 1.2), cf(3.4, 0.55, -1.8, 0, 30, 0), STONE)
		B:block(R, v(0.9, 0.5, 0.8), cf(3.5, 1.15, -1.8, 0, 55, 0), STONE_LT)
		B:block(R, v(1.0, 0.6, 0.9), cf(-3.6, 0.4, 1.8, 0, -20, 0), STONE_DK)
		for _, g in { { -3.4, -0.4 }, { 1.6, 3.4 }, { 3.8, 1.0 }, { -0.8, -3.4 } } do
			B:block(R, v(0.42, 1.2, 0.42), cf(g[1], 0.7, g[2], 0, 20, 8), GRASS)
			B:block(R, v(0.34, 0.8, 0.34), cf(g[1] + 0.36, 0.55, g[2] + 0.16, 0, 40, -12), GRASS_DK)
		end
		local function fern(x, z, yaw, len)
			local fr = CFrame.new(x, 0.45, z) * CFrame.Angles(0, rad(yaw), 0) * CFrame.Angles(rad(26), 0, 0)
			B:block(R, v(0.3, 0.3, len), fr * CFrame.new(0, 0, -len / 2), GREEN_DK)
			for i = 1, 3 do
				B:block(R, v(2.0 - 0.4 * i, 0.2, 0.5), fr * CFrame.new(0, 0.05, -len * 0.22 * i - 0.2), i % 2 == 1 and GREEN or GREEN_LT)
			end
		end
		fern(-3.0, 2.6, -140, 2.6)
		fern(2.6, -3.0, 30, 2.4)

		------------------------------------------------------------ palms
		local function palm(base, H, dir, D, nFr, fl, yaw0)
			dir = v(dir.X, 0, dir.Z).Unit
			local n = 7
			local pts = {}
			for i = 0, n do
				local s = i / n
				pts[i] = base + dir * (D * s ^ 1.7) + v(0, H * s, 0)
			end
			-- root foot
			B:block(R, v(2.8, 0.8, 2.8), CFrame.new(base + v(0, 0.4, 0)), ROOT_DK)
			B:block(R, v(2.5, 1.3, 2.5), CFrame.new(base + v(0, 0.75, 0)) * ang(0, 45, 0), ROOT)
			for k = 0, 2 do
				local a = rad(yaw0 + k * 120)
				local o = v(math.sin(a), 0, math.cos(a))
				B:bar(R, base + v(0, 1.4, 0), base + o * 2.0 + v(0, 0.36, 0), 0.7, 0.6, k == 1 and ROOT_LT or ROOT_DK)
			end
			-- banded trunk
			for i = 0, n - 1 do
				local a, b = pts[i], pts[i + 1]
				local d = (b - a).Unit
				local w = 1.9 - 0.7 * i / (n - 1)
				B:bar(R, (i == 0) and a + v(0, 0.5, 0) or a - d * 0.12, b + d * 0.12, w, w, (i % 2 == 0) and ROOT or ROOT_LT)
				if i > 0 then
					B:bar(R, a - d * 0.18, a + d * 0.18, w + 0.32, w + 0.32, ROOT_DK)
				end
			end
			-- crown knot + nuts
			local T = pts[n]
			B:block(R, v(2.4, 1.4, 2.4), CFrame.new(T + v(0, 0.2, 0)), GREEN_DK)
			B:block(R, v(2.0, 1.0, 2.0), CFrame.new(T + v(0, 0.75, 0)) * ang(0, 45, 0), GREEN)
			for k = 0, 2 do
				local a = rad(yaw0 + 40 + k * 120)
				B:block(R, v(0.9, 0.9, 0.9), CFrame.new(T + v(math.sin(a) * 0.95, -0.55, math.cos(a) * 0.95)) * ang(0, k * 30, 0), k == 1 and ROOT_LT or ROOT_DK)
			end
			-- young spear frond standing up out of the knot
			do
				local C = CFrame.new(T + v(0, 0.9, 0)) * CFrame.Angles(0, rad(yaw0 + 25), 0) * CFrame.Angles(rad(62), 0, 0) * CFrame.new(0, 0, -1.3 * fl)
				B:block(R, v(1.1, 0.28, 2.7 * fl), C * CFrame.Angles(0, 0, rad(-30)) * CFrame.new(0.55, 0, 0), GREEN_TOP)
				B:block(R, v(1.1, 0.28, 2.7 * fl), C * CFrame.Angles(0, 0, rad(30)) * CFrame.new(-0.55, 0, 0), GREEN_TOP)
				B:block(R, v(0.38, 0.4, 2.8 * fl), C * CFrame.new(0, 0.06, 0), GREEN_LT)
			end
			-- fronds
			for f = 0, nFr - 1 do
				local upper = f % 2 == 0
				local yaw = yaw0 + f * 360 / nFr + ((f * 37) % 13 - 6)
				local tone = upper and GREEN_TOP or GREEN
				if f % 3 == 2 then tone = GREEN_DK end
				local F = CFrame.new(T + v(0, 0.8, 0)) * CFrame.Angles(0, rad(yaw), 0) * CFrame.Angles(rad(upper and 32 or 12), 0, 0)
				local segs = { { 3.0 * fl, 2.0, 22 }, { 2.8 * fl, 1.6, 28 }, { 2.4 * fl, 0.75, 0 } }
				for si, sg in segs do
					local len, wh, droop = sg[1], sg[2], sg[3]
					local C = F * CFrame.new(0, 0, -len / 2)
					if si < 3 then
						local roll = 24
						B:block(R, v(wh, 0.28, len + 0.1), C * CFrame.Angles(0, 0, rad(-roll)) * CFrame.new(wh / 2, 0, 0), tone)
						B:block(R, v(wh, 0.28, len + 0.1), C * CFrame.Angles(0, 0, rad(roll)) * CFrame.new(-wh / 2, 0, 0), tone)
						B:block(R, v(0.4, 0.42, len + 0.15), C * CFrame.new(0, 0.06, 0), GREEN_LT)
					else
						B:block(R, v(wh * 1.6, 0.28, len), C * CFrame.new(0, -0.05, 0), tone)
					end
					F = F * CFrame.new(0, 0, -len) * CFrame.Angles(rad(-droop), 0, 0)
				end
			end
		end
		palm(v(0.9, 0, 0.5), 17.2, v(1, 0, 0.25), 6.5, 7, 1.15, 10)
		palm(v(-1.2, 0, 0.9), 14.0, v(-1, 0, 0.6), 5.5, 6, 1.0, 50)
		palm(v(-0.1, 0, -1.4), 9.5, v(-0.25, 0, -1), 3.6, 5, 0.9, 80)
	end,
}
