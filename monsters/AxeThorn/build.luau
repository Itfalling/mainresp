-- Thornwood Greataxe (#8): a living-wood greataxe. A gnarled bark haft wrapped in
-- a thorny briar vine with red roses, a heartwood blade with tree-ring grain, an
-- emerald crystal edge and a sprouting leaf crown. Leaves and petals drift off it.
-- Built standing up: haft along +Y (pommel at Y=0), blade facing +X. Static: no motion.
return {
	DisplayName = "Thornwood Greataxe",
	Rarity = "Divine",
	Element = "Tool",
	Tool = { Name = "Thornwood Greataxe", ToolTip = "Thornwood Greataxe", GripY = -1.555 },
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local BARK, BARK_D, BARK_L = "#94603a", "#6a4224", "#b8804c"
		local WOOD, WOOD_L = "#bb7c43", "#d69d5c"
		local VINE, VINE_D = "#4cb83a", "#2f7f25"
		local LEAF, LEAF_L = "#5cc23d", "#9be35e"
		local THORN = "#efe2b4"
		local ROSE, ROSE_D, ROSE_L = "#f2305c", "#b9173f", "#ff7f9c"
		local EM_D, EM, EM_L, GLOW = "#0f8a48", "#1fc066", "#7ff2ad", "#5dffa0"

		-- stepped crystal / spike: tapering blocks from (x, y) along a direction
		-- `deg` degrees from +Y (positive leans toward +X)
		local function spike(x, y, deg, segs, z)
			local r = math.rad(deg)
			local dx, dy = math.sin(r), math.cos(r)
			local t = 0
			for _, s in segs do
				local len, w, col = s[1], s[2], s[3]
				local c = t + len / 2
				local opt = s[5] and { mat = "Neon" } or nil
				B:block("Root", v(w, len, s[4] or w), cf(x + dx * c, y + dy * c, z or 0, 0, 0, -deg), col, opt)
				t += len - 0.04
			end
		end

		-- a rose facing out of a face (zs = +1 front, -1 back), with two leaves
		local function rose(x, y, z, zs, k)
			B:block("Root", v(0.36 * k, 0.36 * k, 0.12), cf(x, y, z + zs * 0.06), ROSE_D)
			B:block("Root", v(0.3 * k, 0.3 * k, 0.12), cf(x, y, z + zs * 0.14, 0, 0, 45), ROSE)
			B:block("Root", v(0.2 * k, 0.2 * k, 0.1), cf(x, y, z + zs * 0.22), ROSE)
			B:block("Root", v(0.1 * k, 0.1 * k, 0.08), cf(x, y, z + zs * 0.28), ROSE_L)
			B:block("Root", v(0.3 * k, 0.11 * k, 0.06), cf(x - 0.24 * k, y - 0.12 * k, z + zs * 0.05, 0, 0, 30), LEAF)
			B:block("Root", v(0.3 * k, 0.11 * k, 0.06), cf(x + 0.24 * k, y - 0.12 * k, z + zs * 0.05, 0, 0, -30), LEAF)
		end

		-- haft (the Handle): gnarled bark
		B:block("Root", v(0.46, 5.55, 0.46), cf(0, 3.175, 0), BARK, { name = "Handle" })
		B:block("Root", v(0.1, 1.1, 0.06), cf(0.1, 3.3, 0.25), BARK_D)
		B:block("Root", v(0.1, 0.8, 0.06), cf(-0.1, 3.5, -0.25), BARK_D)
		B:block("Root", v(0.06, 0.9, 0.1), cf(0.25, 3.7, -0.08), BARK_D)
		B:block("Root", v(0.06, 0.8, 0.1), cf(-0.25, 3.1, 0.08), BARK_D)
		B:block("Root", v(0.2, 0.22, 0.52), cf(0.12, 2.85, 0), BARK_L) -- knot

		-- pommel: a root knot with roots splaying out and an emerald seed
		B:block("Root", v(0.64, 0.34, 0.64), cf(0, 0.44, 0), BARK_D)
		B:block("Root", v(0.5, 0.2, 0.5), cf(0, 0.18, 0), BARK)
		for _, d in { { 1, 1 }, { -1, 1 }, { 1, -1 }, { -1, -1 } } do
			B:bar("Root", v(0.18 * d[1], 0.4, 0.18 * d[2]), v(0.4 * d[1], 0.06, 0.4 * d[2]), 0.12, 0.12, BARK_D)
		end
		B:gem("Root", v(0.26, 0.1, 0.26), cf(0, 0.05, 0), GLOW)

		-- grip: twisted vine wrap with tilted bands, bark collars
		B:block("Root", v(0.52, 1.6, 0.52), cf(0, 1.62, 0), VINE_D)
		for i, y in { 1.0, 1.42, 1.84, 2.24 } do
			B:block("Root", v(0.58, 0.1, 0.58), cf(0, y, 0, 0, 0, 14), VINE)
		end
		B:block("Root", v(0.64, 0.2, 0.64), cf(0, 0.76, 0), BARK_D)
		B:block("Root", v(0.66, 0.22, 0.66), cf(0, 2.5, 0), BARK_D)

		-- briar vine spiralling up the haft, a thorn at every turn
		local pts = {
			v(0.27, 2.62, 0.27), v(-0.27, 2.94, 0.27), v(-0.27, 3.28, -0.27),
			v(0.27, 3.62, -0.27), v(0.27, 3.94, 0.27), v(-0.27, 4.18, 0.27),
		}
		for i = 1, #pts - 1 do
			B:bar("Root", pts[i], pts[i + 1], 0.11, 0.11, VINE)
		end
		for i, p in pts do
			local o = v(p.X > 0 and 1 or -1, 0.5, p.Z > 0 and 1 or -1)
			B:bar("Root", p, p + o * 0.17, 0.09, 0.09, THORN)
		end
		rose(-0.08, 3.12, 0.23, 1, 0.9)
		rose(0.08, 3.78, -0.23, -1, 0.9)

		local HY = 4.95
		-- the heart: a gnarled wood knot holding the blade, a big rose on each face
		B:block("Root", v(0.84, 1.9, 0.66), cf(0, HY, 0), BARK)
		B:block("Root", v(0.9, 0.22, 0.72), cf(0, HY - 0.91, 0), BARK_D)
		B:block("Root", v(0.9, 0.22, 0.72), cf(0, HY + 0.91, 0), BARK_D)
		B:block("Root", v(0.16, 0.6, 0.7), cf(-0.36, HY + 0.3, 0), BARK_L)
		rose(0, HY, 0.33, 1, 1.3)
		rose(0, HY, -0.33, -1, 1.3)

		-- leaf crown sprouting from the top of the haft, with a rosebud
		B:block("Root", v(0.3, 0.3, 0.3), cf(0, 6.1, 0), BARK)
		B:bar("Root", v(0, 6.2, 0), v(0.08, 6.62, 0), 0.14, 0.14, BARK_D)
		B:bar("Root", v(0, 6.18, 0.02), v(-0.42, 6.46, 0.06), 0.22, 0.07, LEAF)
		B:bar("Root", v(0.04, 6.3, -0.02), v(0.4, 6.6, -0.06), 0.22, 0.07, LEAF_L)
		B:bar("Root", v(0, 6.26, 0.06), v(-0.06, 6.52, 0.36), 0.2, 0.07, LEAF)
		B:bar("Root", v(0, 6.26, -0.06), v(0.06, 6.5, -0.36), 0.2, 0.07, LEAF_L)
		B:block("Root", v(0.34, 0.2, 0.34), cf(0.08, 6.68, 0), ROSE_D)
		B:block("Root", v(0.36, 0.16, 0.36), cf(0.08, 6.8, 0, 0, 45, 0), ROSE)
		B:block("Root", v(0.24, 0.14, 0.24), cf(0.08, 6.92, 0), ROSE)
		B:block("Root", v(0.12, 0.1, 0.12), cf(0.08, 7.02, 0), ROSE_L)

		-- back poll: a thorny branch with one big stepped thorn
		B:block("Root", v(0.36, 0.9, 0.56), cf(-0.56, HY, 0), BARK)
		B:block("Root", v(0.1, 1.0, 0.6), cf(-0.42, HY, 0), BARK_D)
		spike(-0.68, HY + 0.05, -58, {
			{ 0.2, 0.6, BARK_D, 0.44 }, { 0.18, 0.42, BARK, 0.34 }, { 0.16, 0.26, THORN, 0.24 }, { 0.1, 0.12, THORN, 0.14 },
		})

		-- heartwood blade: columns step out and grow taller toward the crystal edge
		local cols = {
			{ 0.66, 0.54, 1.7, 0.54, BARK },
			{ 1.12, 0.46, 2.5, 0.5, WOOD },
			{ 1.56, 0.44, 3.15, 0.46, WOOD },
			{ 1.98, 0.42, 3.6, 0.42, WOOD_L },
		}
		local blade = {}
		for i, c in cols do
			blade[i] = B:block("Root", v(c[2] + 0.02, c[3], c[4]), cf(c[1], HY, 0), c[5])
		end
		-- moss on the inner steps, emerald crystals sprouting on the outer ones
		B:block("Root", v(0.58, 0.14, 0.6), cf(0.66, HY + 0.88, 0), LEAF)
		B:block("Root", v(0.5, 0.14, 0.56), cf(1.12, HY + 1.28, 0), LEAF_L)
		spike(1.56, HY + 1.52, 6, { { 0.16, 0.24, EM }, { 0.14, 0.14, EM_L } })
		spike(1.98, HY + 1.74, -8, { { 0.18, 0.26, EM }, { 0.16, 0.14, EM_L } })

		-- broad emerald crystal edge with glowing seams, crystal horns top and bottom
		B:block("Root", v(0.32, 3.85, 0.4), cf(2.34, HY, 0), EM_D)
		B:block("Root", v(0.24, 4.1, 0.32), cf(2.6, HY, 0), EM)
		B:block("Root", v(0.1, 3.75, 0.22), cf(2.76, HY, 0), EM_L)
		spike(2.56, HY + 2.0, 18, { { 0.2, 0.3, EM }, { 0.18, 0.18, EM_L } })
		spike(2.56, HY - 2.0, 162, { { 0.22, 0.3, EM }, { 0.2, 0.2, EM_L }, { 0.16, 0.1, EM_L } })

		-- blade faces: tree-ring grain, glowing seams and a creeping vine with a rose
		for _, s in { 1, -1 } do
			local function z(t) return s * (t / 2 + 0.02) end
			B:block("Root", v(0.36, 0.06, 0.04), cf(1.12, HY + 0.6, z(0.5)), BARK_D)
			B:block("Root", v(0.36, 0.06, 0.04), cf(1.12, HY - 0.7, z(0.5)), BARK_D)
			B:block("Root", v(0.34, 0.06, 0.04), cf(1.56, HY + 0.95, z(0.46)), BARK_D)
			B:block("Root", v(0.34, 0.06, 0.04), cf(1.56, HY - 1.0, z(0.46)), BARK_D)
			B:block("Root", v(0.32, 0.06, 0.04), cf(1.98, HY + 1.35, z(0.42)), GLOW, { mat = "Neon" })
			B:block("Root", v(0.32, 0.06, 0.04), cf(1.98, HY - 1.35, z(0.42)), GLOW, { mat = "Neon" })
			B:block("Root", v(0.06, 3.4, 0.04), cf(2.3, HY, z(0.4)), GLOW, { mat = "Neon" })
			B:block("Root", v(0.05, 2.8, 0.04), cf(2.6, HY, z(0.32)), GLOW, { mat = "Neon" })
			-- pale crystal facets on the emerald edge
			B:block("Root", v(0.14, 0.9, 0.04), cf(2.42, HY + 1.2, z(0.4)), EM_L)
			B:block("Root", v(0.14, 0.7, 0.04), cf(2.42, HY - 1.3, z(0.4)), EM_L)
			B:block("Root", v(0.12, 0.6, 0.04), cf(2.66, HY + 0.2, z(0.32)), EM_L)
			-- vine creeping out from the heart across the blade
			local a, b, c = v(0.42, HY - 0.45, z(0.54)), v(1.15, HY - 0.1, z(0.5)), v(1.9, HY - 0.4, z(0.42))
			B:bar("Root", a, b, 0.09, 0.09, VINE)
			B:bar("Root", b, c, 0.09, 0.09, VINE)
			B:bar("Root", b, b + v(0.12, 0.3, 0), 0.07, 0.07, THORN)
			B:block("Root", v(0.28, 0.1, 0.05), cf(1.62, HY - 0.1, z(0.46), 0, 0, 25), LEAF_L)
			B:block("Root", v(0.28, 0.1, 0.05), cf(0.85, HY - 0.4, z(0.52), 0, 0, -20), LEAF)
			rose(1.9, HY - 0.4, z(0.42), s, 0.7)
		end

		-- falling leaves and rose petals, emerald sparkles, a soft green glow
		B:emitter(blade[3], "leaf", { color = { "#7fdc4a", "#3d9a2f" }, rate = 3, name = "Leaves" })
		B:emitter(blade[2], "leaf", { color = { "#ff6a8a", "#e3264f" }, rate = 2, size = { 0.28, 0.28, 0.15 }, name = "Petals" })
		B:emitter(blade[4], "sparkle", { color = { "#b6ffd0", "#5dffa0" }, rate = 6, size = { 0.08, 0.3, 0 }, name = "EmeraldSparkle" })
		B:light(blade[4], { color = "#7dffb0", brightness = 0.8, range = 7, name = "ThornLight" })
	end,
}
