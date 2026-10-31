-- Treadmill11 "Frost Treadmill" (tier 10, Legendary).
-- Ice crystal frame: translucent ice pillars, stepped crystal spires at the
-- rear, icicles, snow caps and ice-brick side panels. Faces -Z (console front).
-- Animated: frosty belt (slats + glowing frost seams slide +Z), four spinning
-- snowflake roller hubs, a faceted ice crystal spinning above the console with
-- three orbiting ice shards (trails), chase lights along the frame, a frost
-- equalizer + thermometer on the screen, twinkling icicle tips, pulsing spire
-- cores and a "freeze burst" beat (crystal whirl, shards fly out, snow puff).
return {
	DisplayName = "Frost Treadmill",
	Rarity = "Legendary",
	Element = "Ice",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local ICE, ICE_D, ICE_L = "#9fdcff", "#4a90cc", "#dff6ff"
		local NAVY, NAVY_D, SNOW = "#24467a", "#152a4d", "#f7fcff"
		local GLASS, FROST = "#bfe9ff", "#cfeeff"
		local NEON, NEON2 = "#7af4ff", "#e9fdff"
		local CR = 0.2 -- crystal translucency

		---------------------------------------------------------------- base
		B:block("Root", v(5.4, 0.3, 10.2), cf(0, 0.15, -0.1), NAVY_D)
		B:block("Root", v(5.0, 0.8, 9.8), cf(0, 0.7, -0.1), ICE_D)
		B:block("Root", v(5.1, 0.12, 9.9), cf(0, 1.06, -0.1), ICE_L)
		-- ice-brick side panels + chase-light strip (lights named, no sym)
		for _, s in { 1, -1 } do
			for i = 0, 7 do
				local z = -4.35 + i * 1.18
				B:block("Root", v(0.14, 0.5, 1.1), cf(s * 2.55, 0.55, z), i % 2 == 0 and ICE or ICE_L)
			end
			B:block("Root", v(0.16, 0.16, 9.6), cf(s * 2.56, 0.92, -0.1), NAVY)
		end
		for i = 1, 8 do
			local z = -4.1 + (i - 1) * 1.15
			B:block("Root", v(0.1, 0.12, 0.8), cf(2.66, 0.92, z), NEON, { mat = "Neon", name = "ChR" .. i })
			B:block("Root", v(0.1, 0.12, 0.8), cf(-2.66, 0.92, z), NEON, { mat = "Neon", name = "ChL" .. i })
		end

		-- foot rails either side of the belt (frosted, snow caps at the ends)
		B:sym(function()
			B:block("Root", v(0.8, 0.3, 7.0), cf(2.1, 1.35, 0.1), ICE_L)
			B:block("Root", v(0.82, 0.08, 6.4), cf(2.1, 1.52, 0.1), FROST)
			B:block("Root", v(0.9, 0.25, 0.6), cf(2.1, 1.6, 3.35), SNOW)
		end)
		-- belt bed
		B:block("Root", v(3.5, 0.1, 8.4), cf(0, 1.17, 0.1), NAVY_D)

		-------------------------------------------------- belt (slides +Z)
		-- 2-slat pattern (period 1.0): frost-white slat, pale-ice slat with a
		-- glowing frost seam. Slats run from under the hood to under the cap.
		local belt = B:bone("Belt", "Root", v(0, 1.3, 0))
		for i = 0, 16 do
			local z = -4.4 + i * 0.5
			if i % 2 == 0 then
				B:block(belt, v(3.4, 0.08, 0.4), cf(0, 1.27, z), SNOW)
			else
				B:block(belt, v(3.4, 0.08, 0.4), cf(0, 1.27, z), "#a9dcff")
				B:block(belt, v(3.3, 0.03, 0.08), cf(0, 1.32, z + 0.22), NEON, { mat = "Neon" })
			end
		end

		-------------------------------------------- motor hood + rear cap
		B:block("Root", v(5.0, 0.9, 1.6), cf(0, 1.45, -4.2), ICE_D)
		B:block("Root", v(4.8, 0.2, 1.5), cf(0, 2.0, -4.2), ICE_L)
		B:block("Root", v(3.2, 0.12, 0.9), cf(0, 2.15, -4.25), NAVY)
		B:block("Root", v(2.2, 0.06, 0.2), cf(0, 2.22, -3.95), NEON, { mat = "Neon" })
		-- snow caps on the hood corners
		B:sym(function()
			B:block("Root", v(1.0, 0.3, 1.0), cf(2.0, 2.2, -4.4), SNOW)
			B:block("Root", v(0.6, 0.2, 0.6), cf(2.1, 2.42, -4.5), SNOW)
		end)
		B:block("Root", v(5.0, 0.6, 1.3), cf(0, 1.35, 4.25), ICE_D)
		B:block("Root", v(5.1, 0.12, 1.4), cf(0, 1.68, 4.25), ICE_L)
		-- rear frost vents (mist)
		local ventR = B:block("Root", v(0.9, 0.25, 0.7), cf(0.7, 1.82, 4.45), NAVY)
		local ventL = B:block("Root", v(0.9, 0.25, 0.7), cf(-0.7, 1.82, 4.45), NAVY)
		for _, x in { 0.7, -0.7 } do
			for k = -1, 1 do
				B:block("Root", v(0.8, 0.06, 0.1), cf(x, 1.96, 4.45 + k * 0.2), ICE_L)
			end
		end

		-- icicles hanging off the hood front edge (tips twinkle)
		local tipN = 0
		local function icicle(top, len, w)
			B:block("Root", v(w, len * 0.6, w), CFrame.new(top - Vector3.new(0, len * 0.3, 0)), GLASS, { tr = 0.15 })
			B:block("Root", v(w * 0.55, len * 0.45, w * 0.55), CFrame.new(top - Vector3.new(0, len * 0.6 + len * 0.2, 0)), GLASS, { tr = 0.15 })
			tipN += 1
			B:block("Root", v(w * 0.3, len * 0.16, w * 0.3), CFrame.new(top - Vector3.new(0, len * 0.98, 0)), NEON2, { mat = "Neon", name = "IcTip" .. tipN })
		end
		for i, x in { -1.2, -0.4, 0.4, 1.2 } do
			icicle(Vector3.new(x, 4.75, 4.3), ({ 0.6, 0.85, 0.7, 0.5 })[i], 0.24)
		end
		for i, x in { -2.0, -1.2, -0.4, 0.4, 1.2, 2.0 } do
			icicle(Vector3.new(x, 1.95, -5.05), ({ 0.7, 0.5, 0.8, 0.6, 0.45, 0.75 })[i], 0.26)
		end

		------------------------------------------------- crystal clusters
		local function crystal(base, h, w, tiltX, tiltZ, glow)
			local c = CFrame.new(base) * ang(tiltX, 45, tiltZ)
			B:block("Root", v(w, h * 0.65, w), c * CFrame.new(0, h * 0.325, 0), ICE, { tr = CR })
			B:block("Root", v(w * 0.65, h * 0.3, w * 0.65), c * CFrame.new(0, h * 0.8, 0), GLASS, { tr = CR })
			B:block("Root", v(w * 0.3, h * 0.14, w * 0.3), c * CFrame.new(0, h * 1.0, 0), glow and NEON or SNOW, glow and { mat = "Neon" } or nil)
		end
		-- front corners: ground clusters
		B:sym(function()
			crystal(Vector3.new(2.75, 0, -4.95), 1.9, 0.6, -14, 0, -14)
			crystal(Vector3.new(2.95, 0, -4.2), 1.3, 0.45, 0, 0, -22)
			crystal(Vector3.new(2.45, 0, -5.3), 1.1, 0.4, -25, 0, 0)
		end)
		-- rear corner spires (big stepped icebergs) with glowing cores
		for _, s in { 1, -1 } do
			local x = 1.95 * s
			B:block("Root", v(1.3, 0.5, 1.3), cf(x, 1.95, 4.3), SNOW)
			B:block("Root", v(1.1, 1.6, 1.1), cf(x, 2.95, 4.3, 0, 45, 0), ICE, { tr = CR })
			B:block("Root", v(0.85, 1.3, 0.85), cf(x, 4.35, 4.3, 0, 0, 0), GLASS, { tr = CR })
			B:block("Root", v(0.6, 1.0, 0.6), cf(x, 5.45, 4.3, 0, 45, 0), ICE, { tr = CR })
			B:block("Root", v(0.34, 0.6, 0.34), cf(x, 6.2, 4.3), NEON2, { mat = "Neon", name = s > 0 and "SpTipR" or "SpTipL" })
			B:block("Root", v(0.36, 3.6, 0.36), cf(x, 4.0, 4.3), NEON, { mat = "Neon", name = s > 0 and "SpCoreR" or "SpCoreL" })
			-- side shards leaning outward
			B:block("Root", v(0.45, 1.4, 0.45), cf(x + 0.65 * s, 2.6, 4.0, 0, 45, -22 * s), ICE, { tr = CR })
			B:block("Root", v(0.25, 0.4, 0.25), cf(x + 0.95 * s, 3.35, 4.0, 0, 45, -22 * s), SNOW)
			B:block("Root", v(0.4, 1.1, 0.4), cf(x + 0.2 * s, 2.5, 4.95, 24, 45, 0), GLASS, { tr = CR })
			B:block("Root", v(0.35, 1.0, 0.35), cf(x + 0.55 * s, 3.9, 4.6, 18, 45, -16 * s), ICE, { tr = CR })
			-- snow ledge
			B:block("Root", v(1.0, 0.2, 1.0), cf(x, 3.8, 4.3, 0, 45, 0), SNOW)
		end

		------------------------------------------ snowflake roller hubs
		-- 6-arm snowflakes in the YZ plane, spinning about X.
		local function snowflake(name, x, y, z, r, trail, base)
			local c = base or cf(x, y, z)
			local b = B:bone(name, "Root", c)
			for k = 0, 2 do
				B:block(b, v(0.18, 0.2, 2 * r), c * ang(60 * k, 0, 0), ICE_L)
			end
			for k = 0, 5 do
				local a = c * ang(60 * k, 0, 0)
				B:block(b, v(0.2, 0.12, 0.5 * r), a * CFrame.new(0.01, 0, -0.62 * r) * ang(90, 0, 0), SNOW)
				B:block(b, v(0.22, 0.16, 0.16), a * CFrame.new(0.02, 0, -r), GLASS)
			end
			B:block(b, v(0.24, 0.5 * r + 0.1, 0.5 * r + 0.1), c * ang(45, 0, 0), ICE_D)
			B:block(b, v(0.28, 0.22, 0.22), c, NEON, { mat = "Neon" })
			if trail then
				B:trail(b, v(x, y + r * 0.6, z), v(x, y + r, z), { color = { NEON2, NEON }, life = 0.22, trans = { 0.3, 1 }, name = name .. "Trail" })
			end
		end
		snowflake("HubFR", 2.66, 1.45, -4.2, 0.75, true)
		snowflake("HubFL", -2.66, 1.45, -4.2, 0.75, true)
		snowflake("HubRR", 2.66, 1.3, 4.25, 0.6, false)
		snowflake("HubRL", -2.66, 1.3, 4.25, 0.6, false)

		-------------------------------- rear ice bridge + giant snowflake
		B:block("Root", v(3.4, 0.55, 0.9), cf(0, 5.25, 4.3), ICE, { tr = CR })
		B:block("Root", v(3.0, 0.2, 1.0), cf(0, 5.6, 4.3), SNOW)
		B:block("Root", v(2.2, 0.25, 0.7), cf(0, 4.88, 4.3), GLASS, { tr = CR })
		B:block("Root", v(1.0, 0.35, 0.8), cf(0, 5.85, 4.3), ICE_D)
		B:block("Root", v(0.9, 0.08, 0.85), cf(0, 5.72, 4.3), NEON, { mat = "Neon", name = "BridgeGlow" })
		-- giant snowflake spinning about Z above the bridge (faces the camera behind)
		snowflake("BigFlake", 0, 7.3, 4.3, 1.3, true, cf(0, 7.3, 4.3) * ang(0, 90, 0))

		------------------------------------------------------ uprights
		B:sym(function()
			local a, b = v(2.15, 1.6, -4.5), v(2.15, 5.4, -4.0)
			B:bar("Root", a, b, 0.75, 0.75, ICE, { tr = 0.1 })
			B:bar("Root", v(2.15, 1.7, -4.5), v(2.15, 5.3, -4.0), 0.3, 0.8, ICE_L)
			B:block("Root", v(1.0, 0.5, 1.0), cf(2.15, 1.85, -4.5), ICE_D)
			-- crystal growths along the pillar
			B:block("Root", v(0.4, 0.8, 0.4), cf(2.6, 2.9, -4.4, 0, 45, -28), ICE, { tr = CR })
			B:block("Root", v(0.3, 0.6, 0.3), cf(2.55, 3.95, -4.25, 0, 45, -35), GLASS, { tr = CR })
			B:block("Root", v(0.22, 0.25, 0.22), cf(2.76, 3.35, -4.47, 0, 45, -28), SNOW)
		end)

		------------------------------------------------------- console
		local con = cf(0, 5.8, -3.9) * ang(-30, 0, 0)
		B:block("Root", v(4.8, 1.0, 1.4), con, ICE_D)
		B:block("Root", v(4.9, 0.22, 1.5), con * CFrame.new(0, 0.58, 0), ICE_L)
		B:block("Root", v(4.6, 0.2, 1.3), con * CFrame.new(0, -0.58, 0), NAVY)
		B:block("Root", v(5.0, 0.3, 0.3), con * CFrame.new(0, 0.62, 0.62), SNOW)
		-- screen
		B:block("Root", v(3.0, 0.78, 0.06), con * CFrame.new(0.1, 0.0, 0.7), NAVY_D)
		B:block("Root", v(3.15, 0.08, 0.08), con * CFrame.new(0.1, 0.42, 0.7), ICE_L)
		B:block("Root", v(3.15, 0.08, 0.08), con * CFrame.new(0.1, -0.42, 0.7), ICE_L)
		-- frost equalizer (8 bars)
		for i = 1, 8 do
			local hgt = 0.1 + (i - 1) * 0.06
			B:block("Root", v(0.2, hgt, 0.05), con * CFrame.new(-1.2 + (i - 1) * 0.27, -0.32 + hgt / 2, 0.74), i > 6 and NEON2 or NEON, { mat = "Neon", name = "Bar" .. i })
		end
		-- snowflake icon + thermometer
		B:block("Root", v(0.5, 0.08, 0.05), con * CFrame.new(1.05, 0.1, 0.74), NEON2, { mat = "Neon" })
		B:block("Root", v(0.5, 0.08, 0.05), con * CFrame.new(1.05, 0.1, 0.74) * ang(0, 0, 60), NEON2, { mat = "Neon" })
		B:block("Root", v(0.5, 0.08, 0.05), con * CFrame.new(1.05, 0.1, 0.74) * ang(0, 0, -60), NEON2, { mat = "Neon" })
		B:block("Root", v(0.14, 0.7, 0.05), con * CFrame.new(1.45, 0, 0.73), ICE_L)
		for i = 1, 4 do
			B:block("Root", v(0.1, 0.13, 0.05), con * CFrame.new(1.45, -0.26 + (i - 1) * 0.16, 0.76), NEON, { mat = "Neon", name = "Th" .. i })
		end
		-- buttons
		B:block("Root", v(0.36, 0.26, 0.12), con * CFrame.new(-1.95, 0.15, 0.7), GLASS)
		B:block("Root", v(0.36, 0.26, 0.12), con * CFrame.new(-1.95, -0.18, 0.7), ICE)
		B:block("Root", v(0.4, 0.4, 0.12), con * CFrame.new(2.0, 0.0, 0.7), SNOW)
		B:block("Root", v(0.2, 0.2, 0.06), con * CFrame.new(2.0, 0.0, 0.78), NEON, { mat = "Neon", name = "Led" })
		-- snow on the console top + crystal growths at its corners
		B:block("Root", v(1.2, 0.25, 0.9), con * CFrame.new(-1.7, 0.78, -0.1), SNOW)
		B:block("Root", v(0.8, 0.2, 0.7), con * CFrame.new(1.8, 0.76, 0.0), SNOW)
		B:sym(function()
			B:block("Root", v(0.45, 1.1, 0.45), con * CFrame.new(2.45, 0.7, -0.2) * ang(0, 45, -25), ICE, { tr = CR })
			B:block("Root", v(0.25, 0.3, 0.25), con * CFrame.new(2.7, 1.25, -0.2) * ang(0, 45, -25), SNOW)
		end)
		-- icicles under the console
		for i, x in { -1.6, -0.9, -0.2, 0.5, 1.2, 1.8 } do
			local p = (con * CFrame.new(x, -0.62, 0.55)).Position
			icicle(p, ({ 0.5, 0.75, 0.45, 0.65, 0.8, 0.5 })[i], 0.22)
		end

		-- pedestal for the ice crystal
		B:block("Root", v(1.6, 0.35, 1.2), cf(0, 6.45, -4.15), ICE_D)
		B:block("Root", v(1.2, 0.3, 0.9), cf(0, 6.75, -4.15), ICE_L)
		B:block("Root", v(1.3, 0.08, 1.0), cf(0, 6.62, -4.15), NEON, { mat = "Neon", name = "PedRing" })

		------------------------------------------ rotating ice crystal
		-- tall faceted bipyramid: stepped layers alternately turned 45 degrees,
		-- translucent so the glowing core shows through.
		local CY = 7.9
		local crys = B:bone("Crystal", "Root", v(0, CY, -4.15))
		local layers = { { 0.25, -1.45, 0.3 }, { 0.5, -1.15, 0.35 }, { 0.78, -0.8, 0.4 }, { 1.05, -0.4, 0.45 }, { 1.25, 0.05, 0.5 }, { 1.05, 0.5, 0.45 }, { 0.8, 0.92, 0.42 }, { 0.55, 1.3, 0.38 }, { 0.32, 1.64, 0.34 } }
		for i, l in layers do
			local col = (i == 5) and ICE_L or (i % 2 == 0 and GLASS or ICE)
			B:block(crys, v(l[1], l[3], l[1]), cf(0, CY + l[2], -4.15, 0, i % 2 == 0 and 45 or 0, 0), col, { tr = 0.3 })
		end
		local core = B:block(crys, v(0.42, 2.2, 0.42), cf(0, CY + 0.1, -4.15, 0, 22, 0), NEON, { mat = "Neon", name = "CrysCore" })
		B:block(crys, v(0.16, 0.36, 0.16), cf(0, CY + 1.95, -4.15), NEON2, { mat = "Neon" })
		B:block(crys, v(0.14, 0.3, 0.14), cf(0, CY - 1.72, -4.15), NEON2, { mat = "Neon" })
		-- equator band of frost studs
		for k = 0, 3 do
			B:block(crys, v(0.22, 0.22, 0.22), cf(0, CY + 0.05, -4.15, 0, 90 * k + 45, 0) * CFrame.new(0.88, 0, 0) * ang(0, 0, 45), NEON2, { mat = "Neon" })
		end
		B:light(core, { color = NEON, brightness = 1.0, range = 12, name = "CrystalLight" })
		B:emitter(core, "sparkle", { color = { NEON2, NEON }, rate = 10, size = { 0.15, 0.4, 0 }, speed = { 0.5, 1.6 }, name = "CrysSparkle" })
		B:emitter(core, "leaf", { color = { "#ffffff", "#d9f6ff" }, rate = 9, size = { 0.25, 0.3, 0.15 }, speed = { 1, 2.5 }, life = { 2, 3.5 }, accel = { 0, -1.5, 0 }, spread = 80, light = 0.4, name = "Snow" })
		B:emitter(core, "burst", { color = { "#ffffff", NEON }, size = { 0.5, 0.35, 0 }, speed = { 6, 12 }, name = "FreezeBurst" })

		-- three orbiting ice shards (each on its own bone so they can fly out)
		local ring = B:bone("ShardRing", "Root", v(0, CY, -4.15))
		for k = 1, 3 do
			local a = math.rad(120 * (k - 1))
			local px, pz = math.sin(a) * 1.5, -4.15 + math.cos(a) * 1.5
			local sb = B:bone("Shard" .. k, ring, v(px, CY, pz))
			B:block(sb, v(0.34, 0.5, 0.34), cf(px, CY, pz, 0, 45, 0), ICE, { tr = 0.2 })
			B:block(sb, v(0.22, 0.3, 0.22), cf(px, CY + 0.38, pz), GLASS, { tr = 0.2 })
			B:block(sb, v(0.22, 0.3, 0.22), cf(px, CY - 0.38, pz), GLASS, { tr = 0.2 })
			B:block(sb, v(0.1, 0.22, 0.1), cf(px, CY + 0.62, pz), NEON2, { mat = "Neon" })
			B:block(sb, v(0.1, 0.22, 0.1), cf(px, CY - 0.62, pz), NEON2, { mat = "Neon" })
			B:trail(sb, v(px, CY - 0.4, pz), v(px, CY + 0.4, pz), { color = { NEON2, NEON }, life = 0.45, trans = { 0.3, 1 }, name = "ShardTrail" .. k })
		end
		-- tilted frost halo of six snow motes circling the pedestal
		local halo = B:bone("FrostHalo", "Root", CFrame.new(0, 7.15, -4.15) * ang(12, 0, 0))
		B:ring(halo, CFrame.new(0, 7.15, -4.15) * ang(12, 0, 0), 1.15, 6, v(0.2, 0.2, 0.2), NEON2, { mat = "Neon" })
		B:ring(halo, CFrame.new(0, 7.15, -4.15) * ang(12, 30, 0), 1.15, 6, v(0.26, 0.12, 0.26), ICE_L)

		----------------------------------------------- handrails
		B:sym(function()
			B:bar("Root", v(2.35, 5.15, -3.5), v(2.35, 4.4, -0.7), 0.4, 0.4, ICE_L)
			B:bar("Root", v(2.35, 4.95, -2.6), v(2.35, 4.5, -1.0), 0.5, 0.5, SNOW)
			B:block("Root", v(0.55, 0.3, 0.55), cf(2.35, 4.4, -0.75), ICE_D)
		end)
		-- icicles hanging under the handrails
		for _, s in { 1, -1 } do
			for k, z in { -2.9, -2.2, -1.5 } do
				local y = 5.15 + (z + 3.5) / 2.8 * (4.4 - 5.15) - 0.2
				icicle(Vector3.new(2.35 * s, y, z), ({ 0.5, 0.7, 0.45 })[k], 0.18)
			end
		end

		---------------------------------------------- mist + snow emitters
		B:emitter(ventR, "smoke", { color = { "#f2fbff", "#bfe6ff" }, rate = 3, size = { 0.6, 1.6, 2.4 }, speed = { 0.6, 1.2 }, accel = { 0, 0.6, 0.4 }, name = "MistR" })
		B:emitter(ventL, "smoke", { color = { "#f2fbff", "#bfe6ff" }, rate = 3, size = { 0.6, 1.6, 2.4 }, speed = { 0.6, 1.2 }, accel = { 0, 0.6, 0.4 }, name = "MistL" })
		B:emitter(B:block("Root", v(0.3, 0.3, 0.3), cf(1.95, 6.25, 4.3), NEON2, { tr = 1 }), "sparkle", { color = { NEON2, NEON }, rate = 5, name = "SpireSparkR" })
		B:emitter(B:block("Root", v(0.3, 0.3, 0.3), cf(-1.95, 6.25, 4.3), NEON2, { tr = 1 }), "sparkle", { color = { NEON2, NEON }, rate = 5, name = "SpireSparkL" })
	end,
}
