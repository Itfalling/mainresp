-- Treadmill14 "Divine Treadmill" (tier 13). Faces -Z (console at the front).
-- A white-marble + gold temple treadmill floating on clouds:
--   * stepped marble dais, deep-sky belt with white slats + gold light seams
--   * fluted gold-capped columns carrying the console, a glory HALO (sunburst
--     ring) floating behind the console that rotates, angel WINGS that flap
--   * a temple arch over the runner with ascending light strips and a small
--     floating halo spinning above the runner's head
--   * light motes, drifting feathers, orbiting light cubes, bobbing clouds
return {
	DisplayName = "Divine Treadmill",
	Rarity = "Divine",
	Element = "Holy",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local W1, W2, W3 = "#fffdf6", "#ece4d0", "#c8bda2" -- marble
		local G1, G2, G3 = "#ffe07a", "#f0b22e", "#b47a16" -- gold
		local NGOLD, NSKY = "#ffe991", "#8fe9ff" -- neon accents
		local BED, SCREEN = "#3a4a8e", "#18204c"

		---------------------------------------------------------------- dais
		B:block("Root", v(6.4, 0.3, 11.4), cf(0, 0.15, -0.1), W3)
		B:block("Root", v(6.25, 0.16, 11.25), cf(0, 0.38, -0.1), G3)
		B:block("Root", v(5.8, 0.72, 11.0), cf(0, 0.8, -0.1), W2)
		-- gold belt line + marble panels on each side
		B:sym(function(side)
			B:block("Root", v(0.1, 0.12, 10.6), cf(2.92, 1.08, -0.1), G2)
			for i = 0, 3 do
				B:block("Root", v(0.08, 0.42, 1.9), cf(2.9, 0.72, -3.0 + i * 2.1), W1)
				B:block("Root", v(0.1, 0.12, 0.12), cf(2.95, 0.98, -3.0 + i * 2.1 - 0.75), G1)
				B:block("Root", v(0.1, 0.12, 0.12), cf(2.95, 0.98, -3.0 + i * 2.1 + 0.75), G1)
			end
		end)
		-- side running rails (where the runner can step aside)
		B:sym(function(side)
			B:block("Root", v(1.0, 0.32, 8.6), cf(2.2, 1.3, 0.2), W1)
			B:block("Root", v(0.34, 0.08, 8.62), cf(2.52, 1.49, 0.2), G1)
			B:block("Root", v(0.12, 0.1, 8.62), cf(1.76, 1.48, 0.2), G3)
		end)
		-- belt bed
		B:block("Root", v(3.5, 0.1, 8.2), cf(0, 1.2, 0.2), BED)

		------------------------------------------- moving belt (period 0.5)
		local belt = B:bone("Belt", "Root", v(0, 1.3, 0))
		for i = 0, 16 do
			local z = -4.0 + i * 0.5
			B:block(belt, v(3.36, 0.07, 0.24), cf(0, 1.29, z), W1)
			B:block(belt, v(3.3, 0.05, 0.06), cf(0, 1.27, z + 0.25), NGOLD, { mat = "Neon" })
		end

		-------------------------------------------------------- front hood
		B:block("Root", v(5.0, 0.95, 1.95), cf(0, 1.62, -4.65), W2)
		B:block("Root", v(5.1, 0.18, 2.05), cf(0, 1.18, -4.65), G2)
		B:block("Root", v(4.7, 0.22, 1.7), cf(0, 2.2, -4.65), W1)
		B:block("Root", v(4.0, 0.12, 1.4), cf(0, 2.36, -4.7), G1)
		-- sun emblem on the nose
		B:block("Root", v(1.0, 1.0, 0.12), cf(0, 1.65, -5.66, 0, 0, 45), G2)
		B:block("Root", v(0.62, 0.62, 0.14), cf(0, 1.65, -5.68, 0, 0, 45), G1)
		B:gem("Root", v(0.3, 0.3, 0.1), cf(0, 1.65, -5.75), NSKY)
		B:sym(function(side)
			B:block("Root", v(0.9, 0.2, 0.1), cf(1.2, 1.65, -5.66), G2)
			B:block("Root", v(0.2, 0.2, 0.1), cf(1.8, 1.65, -5.66), G1)
		end)

		---------------------------------------------------------- rear cap
		B:block("Root", v(4.8, 0.5, 1.2), cf(0, 1.3, 4.6), W2)
		B:block("Root", v(4.9, 0.1, 1.25), cf(0, 1.58, 4.6), G2)
		B:block("Root", v(3.4, 0.08, 0.3), cf(0, 1.6, 4.15), G3)
		-- grand entry stairs
		B:block("Root", v(3.8, 0.6, 0.8), cf(0, 0.6, 5.6), W1)
		B:block("Root", v(3.9, 0.08, 0.85), cf(0, 0.92, 5.6), G2)
		B:block("Root", v(4.4, 0.3, 0.8), cf(0, 0.15, 6.3), W2)
		B:block("Root", v(4.5, 0.08, 0.85), cf(0, 0.33, 6.3), G2)
		-- rear lanterns with flickering holy flames
		B:sym(function(side)
			local x, z = 2.45, 4.55
			B:block("Root", v(0.6, 0.25, 0.6), cf(x, 1.68, z), G3)
			B:block("Root", v(0.3, 0.8, 0.3), cf(x, 2.2, z), W1)
			B:block("Root", v(0.62, 0.12, 0.62), cf(x, 2.62, z), G2)
			for _, o in { { 0.24, 0.24 }, { -0.24, 0.24 }, { 0.24, -0.24 }, { -0.24, -0.24 } } do
				B:block("Root", v(0.1, 0.55, 0.1), cf(x + o[1], 2.95, z + o[2]), G2)
			end
			B:block("Root", v(0.26, 0.36, 0.26), cf(x, 2.88, z), NGOLD, { mat = "Neon", name = "Flame" .. side })
			B:block("Root", v(0.66, 0.14, 0.66), cf(x, 3.28, z), G2)
			B:block("Root", v(0.38, 0.16, 0.38), cf(x, 3.42, z), G1)
			B:block("Root", v(0.14, 0.2, 0.14), cf(x, 3.6, z), G1)
		end)

		----------------------------------------- sunburst roller hubs (spin)
		for _, h in { { "HubFR", 2.98, -4.55 }, { "HubFL", -2.98, -4.55 }, { "HubRR", 2.98, 4.45 }, { "HubRL", -2.98, 4.45 } } do
			local b = B:bone(h[1], "Root", v(h[2], 0.8, h[3]))
			local c = cf(h[2], 0.8, h[3])
			local sx = h[2] > 0 and 1 or -1
			B:block(b, v(0.14, 0.82, 0.82), c, G2)
			B:block(b, v(0.14, 0.82, 0.82), c * ang(45, 0, 0), G2)
			B:block(b, v(0.18, 0.6, 0.16), c * CFrame.new(sx * 0.03, 0, 0), G3)
			B:block(b, v(0.2, 0.26, 0.26), c * CFrame.new(sx * 0.05, 0, 0), W1)
		end

		--------------------------- chase lights along the dais (run to back)
		B:sym(function(side)
			for i = 1, 8 do
				B:block("Root", v(0.1, 0.24, 0.5), cf(2.93, 0.72, -3.5 + (i - 1)), NGOLD, { mat = "Neon", name = "Chase" .. side .. i })
			end
		end)

		------------------------------------------------- columns + console
		B:sym(function(side)
			local x, z = 2.3, -4.25
			B:block("Root", v(1.1, 0.4, 1.1), cf(x, 2.5, z), W2)
			B:block("Root", v(1.0, 0.18, 1.0), cf(x, 2.78, z), G2)
			B:block("Root", v(0.75, 2.4, 0.75), cf(x, 4.0, z), W1)
			-- fluting: darker inset strips on the column faces
			B:block("Root", v(0.2, 2.2, 0.08), cf(x, 4.0, z - 0.38), W2)
			B:block("Root", v(0.2, 2.2, 0.08), cf(x, 4.0, z + 0.38), W2)
			B:block("Root", v(0.08, 2.2, 0.2), cf(x + 0.38, 4.0, z), W2)
			B:block("Root", v(0.86, 0.18, 0.86), cf(x, 3.6, z), G1)
			B:block("Root", v(1.05, 0.3, 1.05), cf(x, 5.3, z), G2)
			B:block("Root", v(1.2, 0.16, 1.2), cf(x, 5.5, z), W2)
			-- handrail with marble grip
			B:bar("Root", v(x + 0.05, 4.65, z + 0.3), v(x + 0.05, 4.3, -1.0), 0.34, 0.34, G2)
			B:bar("Root", v(x + 0.05, 4.57, -3.0), v(x + 0.05, 4.37, -1.5), 0.46, 0.46, W1)
			B:block("Root", v(0.5, 0.5, 0.5), cf(x + 0.05, 4.3, -0.95), G1)
		end)
		local con = cf(0, 5.85, -3.9) * ang(-30, 0, 0)
		B:block("Root", v(4.8, 0.9, 1.3), con, W1)
		B:block("Root", v(4.92, 0.2, 1.42), con * CFrame.new(0, 0.5, 0), G2)
		B:block("Root", v(4.7, 0.16, 1.2), con * CFrame.new(0, -0.5, 0), G3)
		B:block("Root", v(3.4, 0.82, 0.05), con * CFrame.new(0, 0.0, 0.655), G2)
		B:block("Root", v(3.15, 0.66, 0.06), con * CFrame.new(0, 0.0, 0.68), SCREEN)
		for i = 1, 8 do
			local hgt = 0.1 + (i - 1) * 0.06
			B:block("Root", v(0.22, hgt, 0.06), con * CFrame.new(-1.3 + (i - 1) * 0.3, -0.27 + hgt / 2, 0.71), NSKY, { mat = "Neon", name = "Bar" .. i })
		end
		B:block("Root", v(0.42, 0.14, 0.06), con * CFrame.new(1.2, 0.0, 0.71), NGOLD, { mat = "Neon", name = "PulseH" })
		B:block("Root", v(0.14, 0.42, 0.06), con * CFrame.new(1.2, 0.0, 0.715), NGOLD, { mat = "Neon", name = "PulseV" })
		B:block("Root", v(0.36, 0.26, 0.1), con * CFrame.new(-2.0, 0.14, 0.68), G1)
		B:block("Root", v(0.36, 0.26, 0.1), con * CFrame.new(-2.0, -0.18, 0.68), W2)
		B:block("Root", v(0.36, 0.26, 0.1), con * CFrame.new(2.0, 0.14, 0.68), G1)
		B:block("Root", v(0.36, 0.26, 0.1), con * CFrame.new(2.0, -0.18, 0.68), W2)
		-- tiny crown on top of the console
		B:block("Root", v(1.6, 0.25, 0.5), con * CFrame.new(0, 0.72, -0.1), G1)
		B:block("Root", v(0.3, 0.3, 0.3), con * CFrame.new(-0.55, 0.95, -0.1), G2)
		B:block("Root", v(0.3, 0.3, 0.3), con * CFrame.new(0.55, 0.95, -0.1), G2)
		B:gem("Root", v(0.34, 0.4, 0.34), con * CFrame.new(0, 1.0, -0.1), NSKY)

		-------------------------------- glory halo behind the console (spins)
		local GC = v(0, 6.4, -5.25)
		local glory = B:bone("Glory", "Root", GC)
		local gcf = CFrame.new(GC) * ang(90, 0, 0)
		B:ring(glory, gcf, 2.4, 10, v(0.8, 0.5, 0.4), G2)
		B:ring(glory, gcf * ang(0, 18, 0), 2.4, 10, v(0.8, 0.46, 0.4), G1)
		B:ring(glory, gcf * ang(0, 9, 0), 2.0, 12, v(0.5, 0.2, 0.16), W1)
		local rays = B:ring(glory, gcf * ang(0, 22.5, 0), 2.85, 8, v(0.3, 0.3, 0.7), W1)
		B:ring(glory, gcf * ang(0, 22.5, 0) * CFrame.new(0, 0, 0), 3.25, 8, v(0.36, 0.34, 0.2), G2)
		for i = 0, 3 do
			B:block(glory, v(0.42, 0.6, 0.52), gcf * ang(0, i * 90, 0) * CFrame.new(0, 0, -2.4), NGOLD, { mat = "Neon", name = "GloryGem" .. (i + 1) })
		end
		B:trail(glory, GC + v(0, 2.2, 0), GC + v(0, 2.65, 0), { color = { NGOLD, "#ffffff" }, life = 0.45, name = "GloryTrailA" })
		B:trail(glory, GC + v(0, -2.2, 0), GC + v(0, -2.65, 0), { color = { NGOLD, "#ffffff" }, life = 0.45, name = "GloryTrailB" })
		-- light pedestal below the glory halo (projects it)
		B:block("Root", v(1.3, 0.3, 1.0), cf(0, 2.47, -5.2), G3)
		B:block("Root", v(0.7, 0.55, 0.6), cf(0, 2.85, -5.2), W1)
		local lens = B:block("Root", v(0.5, 0.14, 0.4), cf(0, 3.18, -5.2), NGOLD, { mat = "Neon" })
		B:emitter(lens, "glow", { color = { "#fff3b0", NGOLD }, rate = 3, size = { 1.5, 3.2, 1 }, name = "GloryGlow" })
		B:light(lens, { color = "#ffe9a8", brightness = 1.0, range = 12, name = "GloryLight" })
		local burstP = B:block("Root", v(0.4, 0.1, 0.3), cf(0, 3.27, -5.2), G1)
		B:emitter(burstP, "burst", { color = { "#ffffff", NGOLD, NSKY }, size = { 0.7, 0.45, 0 }, name = "Burst" })

		-- light cubes orbiting the glory halo
		for i, m in { { 3.3, -5.75, G1, false }, { 3.3, -5.75, NSKY, true }, { 3.55, -4.9, W1, false }, { 3.55, -4.9, NGOLD, true } } do
			local b = B:bone("Mote" .. i, "Root", v(0, 6.4, m[2]))
			local a = math.rad(i * 90 + 20)
			local p = v(math.cos(a) * m[1], 6.4 + math.sin(a) * m[1], m[2])
			if m[4] then
				B:block(b, v(0.3, 0.3, 0.3), CFrame.new(p) * ang(45, 45, 0), m[3], { mat = "Neon" })
			else
				B:block(b, v(0.36, 0.36, 0.36), CFrame.new(p) * ang(45, 45, 0), m[3])
			end
			if i == 2 or i == 4 then
				B:trail(b, p + v(0, 0, -0.14), p + v(0, 0, 0.14), { color = { m[3], "#ffffff" }, life = 0.5, name = "MoteTrail" .. i })
			end
		end

		--------------------------------------------------- angel wings (flap)
		B:sym(function(side)
			-- wing drawn in its own plane (u = out, w = up), swept back 28 deg
			local WF = CFrame.new(2.7, 5.45, -4.4) * ang(0, -28, 0)
			local function at(u, w, n) return WF * v(u, w, n or 0) end
			local N = at(0, 0, 1) - at(0, 0, 0)
			local root, elbow, tip = at(0, 0), at(1.45, 1.3), at(2.8, 2.3)
			local w1 = B:bone("Wing" .. side, "Root", WF)
			local w2 = B:bone("WingTip" .. side, "Wing" .. side, WF * CFrame.new(1.45, 1.3, 0))
			B:bar(w1, at(-0.3, -0.25), elbow, 0.55, 0.5, G2, { up = N })
			B:bar(w2, elbow, tip, 0.5, 0.46, G2, { up = N })
			B:bar(w2, at(2.0, 1.95, 0), at(3.25, 2.55, 0), 0.34, 0.3, G1, { up = N })
			B:gem(w2, v(0.36, 0.36, 0.36), WF * CFrame.new(3.3, 2.58, 0) * ang(0, 0, 45), NGOLD)
			B:block(w1, v(0.62, 0.62, 0.62), WF * CFrame.new(1.45, 1.3, 0) * ang(0, 0, 45), G1)
			local fi = 0
			local function feather(bone, u, w, deg, len)
				fi += 1
				local du, dw = math.sin(math.rad(deg)), -math.cos(math.rad(deg))
				local p, e = at(u, w), at(u + du * len, w + dw * len)
				B:bar(bone, p, e, 0.6, 0.22, fi % 2 == 0 and W2 or W1, { up = N })
				B:bar(bone, at(u + du * (len - 0.5), w + dw * (len - 0.5)), at(u + du * (len + 0.03), w + dw * (len + 0.03)), 0.68, 0.26, G1, { up = N })
				B:bar(bone, at(u, w, 0.17), at(u + du * len * 0.46, w + dw * len * 0.46, 0.17), 0.72, 0.16, W2, { up = N })
			end
			for k = 0, 5 do
				local u = 0.1 + k * 0.55
				local w = u <= 1.45 and (u / 1.45 * 1.3) or (1.3 + (u - 1.45) / 1.35 * 1.0)
				B:block(k < 3 and w1 or w2, v(0.5, 0.36, 0.34), WF * CFrame.new(u, w + 0.3, 0.02) * ang(0, 0, 40 - k * 3), k % 2 == 0 and G1 or W1)
			end
			for _, f in { { 0.18, 4, 1.4 }, { 0.42, 11, 1.7 }, { 0.66, 18, 2.0 }, { 0.9, 26, 2.25 } } do
				feather(w1, 1.45 * f[1], 1.3 * f[1], f[2], f[3])
			end
			for _, f in { { 0.04, 33, 2.45 }, { 0.28, 41, 2.55 }, { 0.52, 51, 2.45 }, { 0.76, 63, 2.15 }, { 0.98, 77, 1.75 } } do
				feather(w2, 1.45 + 1.35 * f[1], 1.3 + 1.0 * f[1], f[2], f[3])
			end
			B:trail(w2, at(2.9, 2.3), at(3.9, 1.6), { color = { "#ffffff", NGOLD }, life = 0.35, trans = { 0.5, 1 }, name = "WingTrail" .. side })
			local fp = B:block(w2, v(1.2, 0.2, 0.2), WF * CFrame.new(2.4, 0.2, 0), W1, { tr = 1, name = "FeatherSrc" .. side })
			B:emitter(fp, "leaf", { color = { "#ffffff", "#fff4cf" }, rate = 1.2, size = { 0.35, 0.35, 0.2 }, name = "Feathers" .. side })
		end)

		------------------------------------------------- temple arch (runner)
		local AZ = 0.3
		B:sym(function(side)
			local x = 3.6
			B:block("Root", v(1.5, 0.5, 1.5), cf(x, 0.25, AZ), W3)
			B:block("Root", v(1.3, 0.2, 1.3), cf(x, 0.6, AZ), G2)
			B:block("Root", v(0.95, 6.0, 0.95), cf(x, 3.7, AZ), W1)
			B:block("Root", v(0.08, 5.6, 0.3), cf(x + 0.48, 3.75, AZ), W2)
			B:block("Root", v(0.3, 5.6, 0.08), cf(x, 3.75, AZ - 0.48), W2)
			B:block("Root", v(0.3, 5.6, 0.08), cf(x, 3.75, AZ + 0.48), W2)
			B:block("Root", v(1.05, 0.2, 1.05), cf(x, 2.0, AZ), G1)
			B:block("Root", v(1.05, 0.2, 1.05), cf(x, 5.2, AZ), G1)
			B:block("Root", v(1.25, 0.3, 1.25), cf(x, 6.8, AZ), G2)
			-- ascending light strips on the inner face (motion lights them upward)
			for i = 1, 5 do
				B:block("Root", v(0.08, 0.5, 0.3), cf(x - 0.5, 0.6 + i * 1.0, AZ), NSKY, { mat = "Neon", name = "Rise" .. side .. i })
			end
			-- stepped arch half
			for i, s in { { 3.4, 7.3 }, { 2.6, 7.75 }, { 1.8, 8.1 }, { 1.0, 8.35 } } do
				B:block("Root", v(1.0, 0.6, 1.0), cf(s[1], s[2], AZ), W1)
				B:block("Root", v(0.92, 0.14, 1.06), cf(s[1], s[2] - 0.3, AZ), G2)
			end
		end)
		B:block("Root", v(1.3, 0.95, 1.12), cf(0, 8.55, AZ), G2)
		B:block("Root", v(0.9, 0.55, 1.18), cf(0, 8.55, AZ), G1)
		B:gem("Root", v(0.36, 0.36, 1.24), cf(0, 8.55, AZ, 0, 0, 45), NSKY)

		-- golden bells swinging under the arch
		B:sym(function(side)
			local bp = v(1.85, 7.72, AZ)
			local bell = B:bone("Bell" .. side, "Root", bp)
			B:block(bell, v(0.12, 0.4, 0.12), cf(1.85, 7.55, AZ), G3)
			B:block(bell, v(0.4, 0.25, 0.4), cf(1.85, 7.3, AZ), G2)
			B:block(bell, v(0.6, 0.35, 0.6), cf(1.85, 7.03, AZ), G2)
			B:block(bell, v(0.78, 0.14, 0.78), cf(1.85, 6.8, AZ), G1)
			B:block(bell, v(0.18, 0.18, 0.18), cf(1.85, 6.66, AZ), W1)
		end)
		-- heaven beam onto the runner (shown during the blessing)
		B:block("Root", v(1.5, 4.6, 1.5), cf(0, 4.2, AZ), "#fff2b0", { mat = "Neon", tr = 1, name = "Beam" })

		------------------------------------- floating halo above the runner
		local HC = v(0, 7.35, AZ)
		local halo = B:bone("Halo", "Root", HC)
		B:ring(halo, CFrame.new(HC), 1.15, 6, v(0.68, 0.22, 0.28), G1)
		B:ring(halo, CFrame.new(HC) * ang(0, 30, 0), 1.15, 6, v(0.66, 0.2, 0.28), NGOLD, { mat = "Neon" })
		local hgem = B:block(halo, v(0.3, 0.3, 0.3), CFrame.new(HC + v(0, 0, -1.15)) * ang(45, 0, 45), W1)
		B:emitter(hgem, "sparkle", { color = { "#ffffff", NGOLD }, rate = 5, name = "HaloSparkle" })
		B:light(hgem, { color = "#fff0b8", brightness = 0.9, range = 9, name = "HaloLight" })

		-- light motes drifting up over the deck
		local field = B:block("Root", v(3.0, 0.2, 7.0), cf(0, 2.2, 0.3), W1, { tr = 1, name = "MoteField" })
		B:emitter(field, "sparkle", { color = { "#ffffff", NGOLD, NSKY }, rate = 7, speed = { 0.4, 1.2 }, life = { 1.2, 2.2 }, accel = { 0, 0.8, 0 }, name = "Motes" })

		---------------------------------------------- clouds around the base
		for i, c in { { 3.3, -5.9, 1 }, { -3.3, -5.9, 1 }, { 3.6, 5.6, 1 }, { -3.6, 5.6, 1 }, { 4.3, -2.0, 0.85 }, { -4.3, -2.0, 0.85 }, { 4.3, 2.7, 0.85 }, { -4.3, 2.7, 0.85 } } do
			local b = B:bone("Cloud" .. i, "Root", v(c[1], 0.4, c[2]))
			local o, k = c[1] >= 0 and 1 or -1, c[3]
			B:block(b, v(2.4 * k, 0.24, 1.7 * k), cf(c[1], 0.14, c[2]), "#d6e2f5")
			B:block(b, v(2.2 * k, 0.5, 1.5 * k), cf(c[1], 0.5, c[2]), W1)
			B:block(b, v(1.1 * k, 0.5, 1.0 * k), cf(c[1] + 0.4 * o * k, 0.95, c[2] - 0.1), W1)
			B:block(b, v(0.8 * k, 0.4, 0.8 * k), cf(c[1] - 0.55 * o * k, 0.85, c[2] + 0.25), "#f4f7ff")
		end
		local mist = B:block("Root", v(7.5, 0.2, 12.5), cf(0, 0.25, -0.1), W1, { tr = 1, name = "MistSrc" })
		B:emitter(mist, "smoke", { color = { "#ffffff", "#e6eeff" }, rate = 3, size = { 1.5, 3, 4 }, speed = { 0.2, 0.5 }, accel = { 0, 0.1, 0 }, name = "Mist" })
	end,
}
