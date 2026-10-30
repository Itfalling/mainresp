--!nocheck
-- Fire Aloe (Sandy Savanna crop #6, Mythic).
-- A giant desert aloe in the stud-plant style:
-- * stepped golden SAND mound (bone "Soil") with chunky edge blocks,
--   sandstone rocks, dry grass tufts, pebbles, shells, a baby aloe pup and
--   fallen flower tubes
-- * a huge spiky ROSETTE of thick blue-green aloe leaves in three rings,
--   curling upward, with pale spots, cream edge teeth and flame-orange tips
-- * a tall branched flower spike (candelabra) rising out of the centre,
--   carrying four conical racemes of tubular bloom-fruits that grade from
--   glowing gold at the bottom to fiery orange and crimson buds on top
-- Rising embers, warm glow, golden sparkles, one soft light.
-- Static prop: no motion.luau.
return {
	DisplayName = "Fire Aloe",
	Rarity = "Mythic",
	Element = "Fire",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local rad = math.rad

		-- palette (Sandy Savanna) ----------------------------------------
		local SAND_DK, SAND, SAND_LT, SAND_XL = "#c48a45", "#d9a95c", "#e8c27a", "#f2d495"
		local ROCK_DK, ROCK, ROCK_LT = "#a8653a", "#c97f4c", "#e0a46a"
		local GRASS_DK, GRASS, GRASS_LT = "#b39a3a", "#d4bc52", "#ead878"
		local PEB, PEB_LT = "#9c8670", "#bfae96"
		local SHELL, SHELL_PK = "#fbecd8", "#f4b6a4"
		local AL_DK, AL, AL_MID, AL_LT = "#3f7a5a", "#539a6e", "#6cb582", "#8fcb96"
		local SPOT, TOOTH = "#d4ecc0", "#f6ead0"
		local TIP_O, TIP_R = "#ff8a2a", "#e3402a"
		local STALK_DK, STALK, STALK_LT = "#7c5a3a", "#9a7046", "#b98a56"
		local FL_GOLD, FL_ORG, FL_RED, FL_CRIM = "#ffc23a", "#ff8a24", "#f04a2a", "#c22a26"
		local GLOW_Y, GLOW_O = "#ffc83a", "#ff9a2e"

		local seed = 9137
		local function rnd()
			seed = (seed * 16807) % 2147483647
			return seed / 2147483647
		end
		local function jit(a)
			return (rnd() * 2 - 1) * a
		end
		local function pick(t)
			return t[math.floor(rnd() * #t) + 1]
		end
		local function polar(r, deg)
			local a = rad(deg)
			return math.sin(a) * r, -math.cos(a) * r
		end
		local function pv(r, deg, y)
			local x, z = polar(r, deg)
			return v(x, y, z)
		end
		local function hdir(deg)
			local x, z = polar(1, deg)
			return v(x, 0, z)
		end
		local function facing(p, deg)
			return CFrame.new(p) * CFrame.Angles(0, -rad(deg), 0)
		end

		------------------------------------------------------------------
		-- STEPPED SAND MOUND (bone "Soil", parts named "Soil")
		------------------------------------------------------------------
		local soil = B:bone("Soil", "Root", v(0, 0, 0))
		local S = { name = "Soil" }
		local function disc(y0, h, r, col)
			B:block(soil, v(2 * r, h, 1.15 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.15 * r, h - 0.02, 2 * r), cf(0, y0 + h / 2, 0), col, S)
			B:block(soil, v(1.72 * r, h - 0.04, 1.72 * r), cf(0, y0 + h / 2, 0), col, S)
		end
		local function edge(y0, h, r, n, cols, eh, wr, dr)
			for i = 0, n - 1 do
				local a = (i + jit(0.2)) / n * 360
				local w, d = wr[1] + rnd() * (wr[2] - wr[1]), dr[1] + rnd() * (dr[2] - dr[1])
				local hh = h + rnd() * eh - 0.05
				local p = CFrame.Angles(0, rad(a), 0) * CFrame.new(0, y0 + hh / 2, -(r + jit(0.2)))
				B:block(soil, v(w, hh, d), p * ang(0, jit(9), 0), pick(cols), S)
			end
		end
		disc(0, 0.8, 6.5, SAND_DK)
		edge(0, 0.8, 6.55, 16, { SAND_DK, SAND, SAND_DK }, 0.45, { 1.7, 2.5 }, { 1.3, 1.8 })
		disc(0.8, 0.7, 4.8, SAND)
		edge(0.8, 0.7, 4.85, 12, { SAND, SAND_LT, SAND }, 0.35, { 1.5, 2.2 }, { 1.2, 1.6 })
		disc(1.5, 0.6, 3.1, SAND_LT)
		local TOP = 2.1

		-- wind ripples in the sand
		for _, m in { { 10, 5.6, 0.82, 2.4 }, { 130, 5.7, 0.82, 2.2 }, { 250, 5.5, 0.82, 2.5 }, { 315, 5.7, 0.82, 1.9 } } do
			local c = facing(pv(m[2], m[1], m[3]), m[1])
			B:block(soil, v(m[4], 0.18, 0.7), c * ang(-6, 0, 0), SAND_XL, S)
		end
		-- sandstone rocks
		for _, s in { { 5.4, 1.1, 2.8, 1.1, 25, ROCK }, { 6.1, 1.0, 1.3, 0.7, 10, ROCK_LT }, { -5.6, 1.05, -2.4, 1.0, -20, ROCK_DK }, { -4.9, 1.0, -3.7, 0.6, 30, ROCK_LT }, { 1.2, 1.0, 6.0, 0.8, 5, ROCK } } do
			B:block(soil, v(s[4] * 1.35, s[4], s[4] * 1.05), cf(s[1], s[2], s[3], jit(6), s[5], jit(6)), s[6], S)
		end
		B:block(soil, v(0.9, 0.5, 0.8), cf(5.4, 1.85, 2.8, 0, 40, 0), ROCK_LT, S)
		-- dry grass tufts (3-blade)
		for _, g in { { 6.6, -1.8 }, { -2.8, 6.4 }, { -6.7, 1.3 }, { 3.2, -6.2 }, { 4.4, 4.9 } } do
			B:block(soil, v(0.35, 1.2, 0.35), cf(g[1], 0.6, g[2], 0, jit(30), -8), GRASS, S)
			B:block(soil, v(0.3, 0.85, 0.3), cf(g[1] + 0.35, 0.42, g[2] + 0.2, 0, jit(30), 14), GRASS_DK, S)
			B:block(soil, v(0.28, 0.95, 0.28), cf(g[1] - 0.3, 0.47, g[2] - 0.15, 10, jit(30), 0), GRASS_LT, S)
		end
		-- pebbles + shells
		for _, p in { { 4.9, -3.7, PEB }, { -1.6, -5.9, PEB_LT }, { -5.3, 3.9, PEB }, { 5.8, -0.4, PEB_LT } } do
			B:block(soil, v(0.5, 0.32, 0.42), cf(p[1], 0.96, p[2], 0, jit(40), 0), p[3], S)
		end
		for _, p in { { 2.0, -6.0, SHELL }, { -6.0, -0.6, SHELL_PK }, { -3.6, 5.2, SHELL_PK } } do
			B:block(soil, v(0.55, 0.22, 0.45), cf(p[1], 0.92, p[2], 0, jit(40), 0), p[3], S)
			B:block(soil, v(0.3, 0.2, 0.25), cf(p[1], 1.04, p[2], 0, jit(40), 0), SHELL, S)
		end
		-- fallen flower tubes on the sand
		for _, f in { { 30, 5.3, FL_ORG }, { 95, 5.6, FL_GOLD }, { 205, 5.4, FL_RED }, { 290, 5.2, FL_ORG } } do
			B:block(soil, v(0.35, 0.35, 0.9), facing(pv(f[2], f[1], 0.98), f[1] + 70 + jit(30)), f[3], S)
		end

		------------------------------------------------------------------
		-- PLANT (bone "Crop")
		------------------------------------------------------------------
		local crop = B:bone("Crop", "Root", v(0, TOP, 0))

		-- baby aloe pup on the mound
		local function pup(c, s)
			B:block(crop, v(0.8 * s, 0.5 * s, 0.8 * s), c * CFrame.new(0, 0.25 * s, 0), AL_DK)
			for k = 0, 4 do
				local a = k * 72 + 15
				local base = c * CFrame.Angles(0, rad(a), 0) * CFrame.new(0, 0.3 * s, -0.25 * s) * CFrame.Angles(rad(35 + (k % 2) * 15), 0, 0)
				B:block(crop, v(0.45 * s, 0.3 * s, 1.5 * s), base * CFrame.new(0, 0, -0.7 * s), (k % 2 == 0) and AL or AL_MID)
				B:block(crop, v(0.22 * s, 0.22 * s, 0.35 * s), base * CFrame.new(0, 0, -1.55 * s), TIP_O)
			end
		end
		pup(facing(v(-4.6, 0.8, 3.6), 30), 1.0)

		-- AloeLeaf: three thick tapering segments curling upward.
		local function aloeLeaf(deg, r0, y0, e0, curl, segL, w0, cols, teeth, spots)
			local p = pv(r0, deg, y0)
			local out = hdir(deg)
			local widths = { w0, w0 * 0.74, w0 * 0.48 }
			local thick = { 0.9, 0.75, 0.55 }
			local last, dir
			for k = 1, 3 do
				local e = rad(e0 + (k - 1) * curl)
				dir = out * math.cos(e) + v(0, math.sin(e), 0)
				local q = p + dir * segL
				local back = (k == 1) and 0 or 0.35
				local part = B:bar(crop, p - dir * back, q, widths[k], thick[k], cols[k])
				if k == 1 and spots then
					-- pale spots on top of the first segment
					B:block(crop, v(0.35, 0.12, 0.45), part.CFrame * CFrame.new(-widths[k] * 0.22, thick[k] / 2 + 0.03, segL * 0.15), SPOT)
				end
				if k == 2 and teeth == true then
					for sgn = -1, 1, 2 do
						B:block(crop, v(0.38, 0.22, 0.22), part.CFrame * CFrame.new(sgn * (widths[k] / 2 + 0.12), 0.05, sgn * 0.3) * ang(0, sgn * 25, 0), TOOTH)
					end
				end
				p = q
				last = part
			end
			-- flame tip: orange then red point, continuing the curl
			local tipDir = (out * math.cos(rad(e0 + 3 * curl)) + v(0, math.sin(rad(e0 + 3 * curl)), 0)).Unit
			B:bar(crop, p - dir * 0.3, p + tipDir * 0.9, w0 * 0.34, 0.45, TIP_O)
			B:bar(crop, p + tipDir * 0.75, p + tipDir * 1.45, w0 * 0.2, 0.3, TIP_R)
			return last
		end

		-- core block + three rings of leaves
		B:block(crop, v(3.2, 1.2, 3.2), cf(0, TOP + 0.4, 0, 0, 20, 0), AL_DK)
		B:block(crop, v(2.4, 1.0, 2.4), cf(0, TOP + 1.2, 0, 0, 65, 0), AL)
		for i = 0, 8 do
			local a = i * 40 + jit(5)
			aloeLeaf(a, 0.9, TOP + 0.3, 14 + jit(3), 20, 2.7, 2.0, { AL_DK, AL, AL_MID }, true, true)
		end
		for i = 0, 6 do
			local a = i * 360 / 7 + 20 + jit(5)
			aloeLeaf(a, 0.6, TOP + 0.9, 42 + jit(4), 15, 2.5, 1.75, { AL, AL_MID, AL_LT }, false, true)
		end
		for i = 0, 4 do
			local a = i * 72 + 5 + jit(5)
			aloeLeaf(a, 0.35, TOP + 1.4, 64 + jit(4), 8, 1.9, 1.4, { AL_MID, AL_LT, AL_LT }, false, false)
		end

		------------------------------------------------------------------
		-- FLOWER SPIKE (candelabra)
		------------------------------------------------------------------
		local spine = { v(0, TOP + 1.0, 0), v(0.25, 7.5, 0.15), v(0.1, 11.0, 0.0), v(-0.15, 14.2, 0.1), v(-0.1, 15.6, 0.05) }
		for i = 1, #spine - 1 do
			local w = 1.15 - (i - 1) * 0.12
			B:bar(crop, spine[i], spine[i + 1], w, w, (i % 2 == 0) and STALK or STALK_DK)
			if i > 1 then
				-- papery bract at each node
				B:block(crop, v(w + 0.35, 0.35, w + 0.35), CFrame.new(spine[i]) * ang(0, i * 30, 0), STALK_LT)
			end
		end

		-- Raceme: conical cluster of tubular bloom-fruits around an axis.
		local glowParts = {}
		local function raceme(base, top, rmax, tiers, per)
			local axis = (top - base).Unit
			B:bar(crop, base - axis * 0.2, top + axis * 0.4, 0.55, 0.55, STALK)
			for i = 0, tiers - 1 do
				local f = i / (tiers - 1)
				local c = base:Lerp(top, f)
				local r = rmax * (1 - 0.5 * f)
				local droop = 0.75 * (1 - f) - 0.25 * f
				local col, tip, tipS, neon
				if f < 0.3 then
					col, tip, tipS, neon = FL_GOLD, GLOW_Y, 0.62, true
				elseif f < 0.55 then
					col, tip, tipS, neon = FL_ORG, GLOW_O, 0.62, (i % 2 == 0)
				elseif f < 0.8 then
					col, tip, tipS, neon = FL_RED, FL_ORG, 0.6, false
				else
					col, tip, tipS, neon = FL_CRIM, FL_RED, 0.55, false
				end
				local n = (f > 0.8) and math.max(per - 2, 3) or per
				for j = 0, n - 1 do
					local a = j * 360 / n + i * (180 / n)
					local d = hdir(a)
					local q = c + d * r - v(0, droop, 0)
					B:bar(crop, c + d * 0.1, q, 0.55, 0.55, col)
					local t = B:block(crop, v(tipS, tipS, tipS), CFrame.new(q + (q - c).Unit * 0.12) * ang(0, -a, 0) * ang(20, 0, 0), tip, neon and { mat = "Neon", name = "BloomGlow" } or nil)
					if neon then
						table.insert(glowParts, t)
					end
				end
			end
			-- crimson bud cap
			B:block(crop, v(0.85, 0.7, 0.85), CFrame.new(top + axis * 0.3) * ang(0, 30, 0), FL_CRIM)
			B:block(crop, v(0.55, 0.55, 0.55), CFrame.new(top + axis * 0.85) * ang(0, 75, 0), FL_RED)
			B:block(crop, v(0.3, 0.4, 0.3), CFrame.new(top + axis * 1.25) * ang(0, 45, 0), FL_CRIM)
		end

		-- main raceme on top of the spike
		local mainBase = spine[#spine]
		local mainTop = mainBase + v(0, 4.4, 0)
		raceme(mainBase, mainTop, 1.9, 7, 6)
		-- side branches: stalk elbows out, then up to its own raceme
		local function sideBranch(y, deg, r, y1, len, rmax, tiers, per)
			local a = spine[1]:Lerp(spine[#spine], 0)
			local s0
			for i = 1, #spine - 1 do
				if y <= spine[i + 1].Y then
					s0 = spine[i]:Lerp(spine[i + 1], (y - spine[i].Y) / (spine[i + 1].Y - spine[i].Y))
					break
				end
			end
			local elbow = pv(r, deg, y1)
			B:bar(crop, s0, elbow, 0.75, 0.75, STALK)
			B:block(crop, v(0.95, 0.95, 0.95), CFrame.new(elbow) * ang(0, deg, 0), STALK_LT)
			local rb = elbow + v(0, 0.6, 0)
			B:bar(crop, elbow, rb, 0.65, 0.65, STALK_DK)
			raceme(rb, rb + v(0, len, 0), rmax, tiers, per)
		end
		sideBranch(8.8, 70, 3.9, 10.8, 3.6, 1.5, 5, 5)
		sideBranch(10.0, 235, 3.7, 12.0, 3.9, 1.55, 5, 5)

		------------------------------------------------------------------
		-- VFX: warm glow, rising embers, golden sparkles, one soft light
		------------------------------------------------------------------
		local glowZone = B:block(crop, v(2.5, 4.5, 2.5), CFrame.new(mainBase + v(0, 2.0, 0)), FL_ORG, { tr = 1, name = "GlowZone" })
		B:emitter(glowZone, "glow", { name = "FireGlow", color = { "#ffb347", "#ff7a2a" }, rate = 1.5, size = { 2.6, 3.6, 0.6 } })
		B:light(glowZone, { name = "FireLight", color = "#ff9a40", brightness = 1.4, range = 18 })
		local emberZone = B:block(crop, v(9, 8, 9), cf(0, 15.5, 0), FL_ORG, { tr = 1, name = "EmberZone" })
		B:emitter(emberZone, "ember", { name = "RisingEmbers", color = { "#ffe27a", "#ff8a24", "#f04a2a" }, rate = 5, size = { 0.22, 0.14, 0 }, speed = { 0.4, 1.0 }, life = { 1.8, 3.0 }, spread = 40, accel = { 0, 0.8, 0 } })
		B:emitter(emberZone, "sparkle", { name = "GoldSparkle", color = { "#ffe27a", "#fff3c0", "#ffb347" }, rate = 4, size = { 0.12, 0.4, 0 }, life = { 1.2, 2.4 }, speed = { 0.15, 0.5 } })
	end,
}
