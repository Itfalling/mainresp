--!nocheck
-- Dry Grass Tuft (Sandy Savanna filler).
-- A splayed tuft of chunky straw-coloured grass blades in three shades
-- (golden, pale and dark straw) rising from a small dark clump, with two
-- taller stalks carrying brown seed heads. Lightweight scenery meant to be
-- copy-pasted many times: anchored, weld-free, no scripts or effects.
return {
	DisplayName = "Dry Grass Tuft",
	Rarity = "Filler",
	Filler = true,
	Element = "Sandy Savanna",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local rad = math.rad
		local R = "Root"

		-- palette (Sandy Savanna)
		local GRASS, GRASS_DK, GRASS_LT = "#d9b84a", "#b8963a", "#f0d872"
		local SEED, SEED_DK = "#f3e0a0", "#e8c27a"

		local function bar(a, b, w, h, col, ext)
			local c, len = P.aim(a, b)
			ext = ext or 0.1
			B:block(R, v(w, h, len + 2 * ext), c, col)
			return c, len
		end

		B:block(R, v(0.9, 0.3, 0.9), cf(0, 0.15, 0, 0, 25, 0), GRASS_DK)

		-- inner blades: straight, steep. yaw, splay radius, height, colour
		local inner = {
			{ 15, 0.45, 2.0, GRASS },
			{ 95, 0.5, 1.7, GRASS_LT },
			{ 165, 0.4, 2.2, GRASS_DK },
			{ 240, 0.5, 1.9, GRASS_LT },
			{ 310, 0.45, 1.6, GRASS },
		}
		for _, b in inner do
			local a = rad(b[1])
			local dir = v(math.sin(a), 0, -math.cos(a))
			bar(dir * 0.1 + v(0, 0.2, 0), dir * b[2] + v(0, b[3], 0), 0.32, 0.32, b[4])
		end

		-- outer blades: rise, then bend outward and droop.
		-- yaw, knee radius, knee height, tip radius, tip height, colour
		local outer = {
			{ 55, 0.6, 1.2, 1.45, 0.95, GRASS_LT },
			{ 125, 0.55, 1.05, 1.35, 0.65, GRASS },
			{ 200, 0.6, 1.3, 1.5, 1.0, GRASS_LT },
			{ 275, 0.55, 1.0, 1.3, 0.6, GRASS_DK },
			{ 345, 0.6, 1.2, 1.45, 0.85, GRASS },
		}
		for _, b in outer do
			local a = rad(b[1])
			local dir = v(math.sin(a), 0, -math.cos(a))
			local knee = dir * b[2] + v(0, b[3], 0)
			bar(dir * 0.15 + v(0, 0.2, 0), knee, 0.32, 0.32, b[6], 0.12)
			bar(knee, dir * b[4] + v(0, b[5], 0), 0.3, 0.3, b[6], 0.1)
		end

		-- two tall seed stalks with pale wheat heads
		for _, s in { { 60, 0.35, 2.8, SEED }, { 225, 0.3, 2.5, SEED_DK } } do
			local a = rad(s[1])
			local dir = v(math.sin(a), 0, -math.cos(a))
			local top = dir * s[2] + v(0, s[3], 0)
			local c, len = bar(v(0, 0.25, 0), top, 0.18, 0.18, GRASS_DK)
			B:block(R, v(0.32, 0.32, 0.65), c * CFrame.new(0, 0, -len / 2 + 0.15), s[4])
		end
	end,
}
