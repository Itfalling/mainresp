--!nocheck
-- Hallway map: one long straight run through the 10 biomes, dressed with the
-- built decorations / filler / scenery / landmark models (run the build first).
--   lune run tools/build.luau        (or build the ids you changed)
--   lune run tools/map.luau
-- Outputs:
--   out/GardenMap.rbxm          the map as one Model (insert into any place)
--   out/GardenMap.rbxl          ready-to-play place with lighting + spawn
--   out/preview/_map.json       scene for the previewer (node tools/preview/shoot.mjs _map)
--
-- Layout (map space): the run lane is x in [-32, 32], floor top y = 0, the player
-- runs toward +Z. Cliff tiers rise at |x| = 32 (top 14), ~54 (top ~26), ~74 (top ~38).
-- Spawn plaza z 0..60, then 10 stages of 140 studs, then the finale.

local fs = require("@lune/fs")
local luau = require("@lune/luau")
local serde = require("@lune/serde")
local roblox = require("@lune/roblox")
local Instance, CFrame, Vector3, Color3, Enum = roblox.Instance, roblox.CFrame, roblox.Vector3, roblox.Color3, roblox.Enum

local LANE = 32
local STAGE = 140
local PLAZA = 60
local T1 = 14
local ZEND = PLAZA + 10 * STAGE

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local function r4(x)
	return math.floor(x * 10000 + 0.5) / 10000
end

local function cfArr(cf)
	local t = { cf:GetComponents() }
	for i, v in t do
		t[i] = r4(v)
	end
	return t
end

local function color(hex)
	hex = hex:gsub("#", "")
	return Color3.fromRGB(tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16))
end

local function shade(hex, f)
	hex = hex:gsub("#", "")
	local out = "#"
	for i = 1, 5, 2 do
		local v = tonumber(hex:sub(i, i + 1), 16)
		out ..= string.format("%02x", math.clamp(math.floor(v * f + 0.5), 0, 255))
	end
	return out
end

-- deterministic RNG so the map is identical on every build
local outcrops
local seed = 20261031
local function rnd()
	seed = (seed * 1103515245 + 12345) % 2147483648
	return seed / 2147483648
end
local function rint(a, b)
	return a + math.floor(rnd() * (b - a + 1))
end
local function pick(list)
	return list[rint(1, #list)]
end

-- shuffled bag: every item comes up once before any repeats
local function bag(list)
	local items, i = {}, 0
	return function()
		if i >= #items then
			items = table.clone(list)
			for n = #items, 2, -1 do
				local j = rint(1, n)
				items[n], items[j] = items[j], items[n]
			end
			i = 0
		end
		i += 1
		return items[i]
	end
end

local previewParts = {}
local previewInstances = {}

local SURFACES = { "TopSurface", "BottomSurface", "FrontSurface", "BackSurface", "LeftSurface", "RightSurface" }

-- one terrain block (Plastic + studs unless told otherwise)
local function block(parent, size, cf, hex, opts)
	opts = opts or {}
	local p = Instance.new("Part")
	p.Name = opts.name or "Block"
	p.Anchored = true
	p.Size = size
	p.CFrame = cf
	p.Color = color(hex)
	p.Material = opts.mat and Enum.Material[opts.mat] or Enum.Material.Plastic
	p.Transparency = opts.tr or 0
	p.CanCollide = opts.collide ~= false
	if opts.collide == false then
		p.CanTouch = false
		p.CanQuery = false
	end
	p.CastShadow = opts.shadow ~= false
	if opts.studs ~= false then
		for _, f in SURFACES do
			p[f] = Enum.SurfaceType.Studs
		end
	else
		for _, f in SURFACES do
			p[f] = Enum.SurfaceType.Smooth
		end
	end
	p.Parent = parent
	if not opts.hidden then
		table.insert(previewParts, { size = { r4(size.X), r4(size.Y), r4(size.Z) }, cf = cfArr(cf), color = hex, mat = opts.mat or "Plastic", tr = opts.tr or 0 })
	end
	return p
end

-- axis-aligned box from min/max corners
local function box(parent, x0, y0, z0, x1, y1, z1, hex, opts)
	local sx, sy, sz = math.abs(x1 - x0), math.abs(y1 - y0), math.abs(z1 - z0)
	if sx < 0.05 or sy < 0.05 or sz < 0.05 then
		return nil
	end
	return block(parent, Vector3.new(sx, sy, sz), CFrame.new((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), hex, opts)
end

---------------------------------------------------------------------------
-- Model library (out/models/<Id>.rbxm + bounds from out/preview/<Id>.json)
---------------------------------------------------------------------------

local lib = {}
local missing = {}
local function getModel(id)
	if lib[id] ~= nil then
		return lib[id] or nil
	end
	local mp, pp = "out/models/" .. id .. ".rbxm", "out/preview/" .. id .. ".json"
	if not (fs.isFile(mp) and fs.isFile(pp)) then
		lib[id] = false
		table.insert(missing, id)
		return nil
	end
	local model = roblox.deserializeModel(fs.readFile(mp))[1]
	local b = serde.decode("json", fs.readFile(pp)).bounds
	local e = {
		id = id,
		model = model,
		mn = Vector3.new(b.min[1], b.min[2], b.min[3]),
		mx = Vector3.new(b.max[1], b.max[2], b.max[3]),
	}
	e.w = e.mx.X - e.mn.X
	e.d = e.mx.Z - e.mn.Z
	e.h = e.mx.Y - e.mn.Y
	lib[id] = e
	return e
end

local function moveModel(model, offset)
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			d.CFrame = offset * d.CFrame
		end
	end
	local ok, pivot = pcall(function()
		return model.WorldPivot
	end)
	model.WorldPivot = offset * (ok and pivot or CFrame.new())
end

-- footprint half-extents (x, z) of a model after a yaw rotation
local function footprint(e, yaw)
	local c, s = math.abs(math.cos(yaw)), math.abs(math.sin(yaw))
	return (c * e.w + s * e.d) / 2, (s * e.w + c * e.d) / 2
end

-- place a model so its footprint centre lands on (x, z) with its feet at y
local function place(parent, id, x, y, z, yaw, centred)
	local e = getModel(id)
	if not e then
		return nil
	end
	local cx = centred == false and 0 or (e.mn.X + e.mx.X) / 2
	local cz = centred == false and 0 or (e.mn.Z + e.mx.Z) / 2
	local offset = CFrame.new(x, y, z) * CFrame.Angles(0, yaw, 0) * CFrame.new(-cx, -e.mn.Y, -cz)
	if centred == false then
		offset = CFrame.new(x, y, z) * CFrame.Angles(0, yaw, 0)
	end
	local m = e.model:Clone()
	moveModel(m, offset)
	m.Parent = parent
	table.insert(previewInstances, { id = id, cf = cfArr(offset) })
	return m, e
end

---------------------------------------------------------------------------
-- Biomes
---------------------------------------------------------------------------

local BIOMES = {
	{ name = "Sunny Farm", key = "SunnyFarm", ground = { "#6fd44a", "#62c43f" }, cliff = { "#d98a4e", "#c97a40" }, path = "#f2c867", gate = "GateSunnyFarm", accent = "#ffd84a" },
	{ name = "Bunny Meadow", key = "BunnyMeadow", ground = { "#ff8fd0", "#f57cc2" }, cliff = { "#8a5cd6", "#7a4cc4" }, path = "#ffd1ec", gate = "GateBunnyMeadow", accent = "#ff4fb8" },
	{ name = "Harvest Fields", key = "HarvestFields", ground = { "#e8b04a", "#dba23e" }, cliff = { "#a5653a", "#94582f" }, path = "#f2d27a", gate = "GateHarvestFields", accent = "#ff8a1f" },
	{ name = "Thorny Woods", key = "ThornyWoods", ground = { "#3fae47", "#37a03f" }, cliff = { "#7d6a58", "#6d5c4b" }, path = "#b7925f", gate = "GateThornyWoods", accent = "#e8364f", drip = "#2f8a3a" },
	{ name = "Snap-Jaw Jungle", key = "SnapJawJungle", ground = { "#2fbf5a", "#28b050" }, cliff = { "#4f7a3a", "#446d31" }, path = "#79d66a", gate = "GateSnapJaw", accent = "#b4ff3a", drip = "#1f9a45" },
	{ name = "Sandy Savanna", key = "SandySavanna", ground = { "#f0cd7a", "#e6c06b" }, cliff = { "#d8955a", "#c9854b" }, path = "#f7dd98", gate = "GateSandySavanna", accent = "#ff9a3a" },
	{ name = "Misty Swamp", key = "MistySwamp", ground = { "#4f9e6a", "#468f5f" }, cliff = { "#5b5068", "#4e445b" }, path = "#6fae84", gate = "GateMistySwamp", accent = "#7dffcf", drip = "#3d7a4f" },
	{ name = "Honey Hills", key = "HoneyHills", ground = { "#9be04f", "#8ed244" }, cliff = { "#f0a83a", "#e2992e" }, path = "#ffd36b", gate = "GateHoneyHills", accent = "#ffc21a", drip = "#ffb81f" },
	{ name = "Bramble Badlands", key = "BrambleBadlands", ground = { "#b5523c", "#a64833" }, cliff = { "#5a3b36", "#4c312d" }, path = "#d2875a", gate = "GateBrambleBadlands", accent = "#ff5a1f", lava = true },
	{ name = "Starlight Ruins", key = "StarlightRuins", ground = { "#4b56c9", "#4250bb" }, cliff = { "#3a2f6e", "#30275e" }, path = "#c9c4e6", gate = "GateStarlightRuins", accent = "#8ff0ff" },
}

-- per-biome model pools, read from each model's Element + pack
do
	local byName = {}
	for _, b in BIOMES do
		b.decor, b.filler, b.scenery, b.animDecor = {}, {}, {}, {}
		byName[b.name] = b
	end
	local ids = fs.readDir("monsters")
	table.sort(ids)
	for _, id in ids do
		local dir = "monsters/" .. id
		if fs.isFile(dir .. "/pack.txt") and fs.isFile(dir .. "/build.luau") then
			local pack = fs.readFile(dir .. "/pack.txt"):gsub("%s", "")
			local el = fs.readFile(dir .. "/build.luau"):match('Element%s*=%s*"([^"]+)"')
			local b = el and byName[el]
			if b then
				if pack == "Decorations" then
					if fs.isFile(dir .. "/motion.luau") then
						table.insert(b.animDecor, id)
					else
						table.insert(b.decor, id)
					end
				elseif pack == "Filler" then
					table.insert(b.filler, id)
				elseif pack == "Scenery" then
					table.insert(b.scenery, id)
				end
			end
		end
	end
end

---------------------------------------------------------------------------
-- Build
---------------------------------------------------------------------------

local map = Instance.new("Model")
map.Name = "GardenMap"

local origin = Instance.new("Part")
origin.Name = "MapOrigin"
origin.Anchored = true
origin.CanCollide = false
origin.CanQuery = false
origin.CanTouch = false
origin.Transparency = 1
origin.Size = Vector3.new(1, 1, 1)
origin.CFrame = CFrame.new(0, 0, 0)
origin.Parent = map
map.PrimaryPart = origin

local terrainF = Instance.new("Folder")
terrainF.Name = "Terrain"
terrainF.Parent = map
local decoF = Instance.new("Folder")
decoF.Name = "Decorations"
decoF.Parent = map
local landF = Instance.new("Folder")
landF.Name = "Landmarks"
landF.Parent = map
local zonesF = Instance.new("Folder")
zonesF.Name = "Stages"
zonesF.Parent = map
local barrierF = Instance.new("Folder")
barrierF.Name = "Barriers"
barrierF.Parent = map

-- Ocean below the floating island (Roblox parts max out at 2048 per axis)
for i = 0, 1 do
	block(terrainF, Vector3.new(2048, 2, 2048), CFrame.new(0, -31, -400 + i * 2048), "#3fb6d6", { name = "Ocean", studs = false, collide = false, tr = 0.05, shadow = false })
end

-- Cliff column: one stack of strata from y0 to top, grass cap on top.
local function cliff(parent, x0, x1, z0, z1, y0, top, b, capHex)
	local band = 3.5
	local y = y0
	local i = 0
	while y < top - 1.5 - 0.01 do
		local y1 = math.min(y + band, top - 1.5)
		box(parent, x0, y, z0, x1, y1, z1, (i % 2 == 0) and b.cliff[1] or b.cliff[2], { name = "Cliff" })
		y = y1
		i += 1
	end
	-- grass cap with a small lip
	box(parent, x0, top - 1.5, z0, x1, top, z1, capHex, { name = "Grass" })
end

-- hanging drips/vines under an inner cliff lip (moss, honey, vines)
local function drips(parent, x, z0, z1, top, hex, side)
	local z = z0 + rnd() * 3
	while z < z1 - 2 do
		local len = rint(1, 3)
		local w = rint(1, 2)
		for k = 0, len - 1 do
			local hgt = 1.4 + k * 0.2
			box(parent, x - side * 0.6, top - 1.5 - (k + 1) * 1.4, z, x + side * 0.4, top - 1.5 - k * 1.4, z + w - k * 0.3, hex, { name = "Drip" })
			_ = hgt
		end
		z += rint(3, 7)
	end
end

-- chunky rock outcrops stepping out of a cliff face (breaks up the flat walls)
outcrops = function(parent, x, z0, z1, ya, yb, side, b)
	local z = z0 + rnd() * 4
	while z < z1 - 4 do
		local len = rint(4, 9)
		local h = rint(3, 6)
		local y = ya + rnd() * math.max(0, yb - ya - h)
		local dep = 0.8 + rint(0, 2) * 0.6
		local hex = rnd() < 0.5 and shade(b.cliff[1], 1.08) or shade(b.cliff[2], 0.9)
		box(parent, x - side * dep, y, z, x + side * 0.5, y + h, math.min(z + len, z1 - 0.5), hex, { name = "Rock" })
		if rnd() < 0.55 then
			-- a smaller step on top for a stepped, pixel-art look
			local l2 = math.max(2, len - rint(2, 4))
			box(parent, x - side * (dep * 0.5), y + h, z + 1, x + side * 0.5, y + h + rint(1, 2), math.min(z + 1 + l2, z1 - 0.5), shade(hex, 0.94), { name = "Rock" })
		end
		z += len + rint(4, 10)
	end
end

-- lava veins on cliff faces (Badlands)
local function veins(parent, x, z0, z1, top, side)
	local z = z0 + 2
	while z < z1 - 3 do
		local y = 2 + rnd() * (top - 6)
		local len = rint(2, 4)
		for k = 0, len - 1 do
			box(parent, x - side * 0.15, y + k * 1.2, z + k * 0.8, x + side * 0.05, y + k * 1.2 + 1.2, z + k * 0.8 + 1, "#ff6a1f", { name = "LavaVein", mat = "Neon" })
		end
		z += rint(6, 12)
	end
end

local function stageZ(k)
	return PLAZA + (k - 1) * STAGE
end

-- special notches in the side cliffs: { stage, side, z0 (stage-local), z1, id }
local WATERFALLS = {
	{ stage = 1, side = 1, z0 = 60, z1 = 100, id = "MapFarmWaterfall" },
	{ stage = 4, side = -1, z0 = 60, z1 = 100, id = "MapThornWaterfall" },
}
local RIBCAGE_STAGE = 9

local function segmentsFor(k, side)
	-- returns list of {z0, z1, kind}
	local zs = stageZ(k)
	for _, w in WATERFALLS do
		if w.stage == k and w.side == side then
			return {
				{ zs, zs + 30, "cliff" },
				{ zs + 30, zs + w.z0, "cliff" },
				{ zs + w.z0, zs + w.z1, "waterfall", w },
				{ zs + w.z1, zs + 120, "cliff" },
				{ zs + 120, zs + STAGE, "cliff" },
			}
		end
	end
	local segs = {}
	local lens = { 28, 28, 28, 28, 28 }
	local z = zs
	for i, L in lens do
		table.insert(segs, { z, z + L, "cliff" })
		z += L
	end
	-- one alcove per side (two on some), never under the gate, ribcage or finale
	if k ~= RIBCAGE_STAGE then
		local a = rint(2, 4)
		segs[a][3] = "alcove"
		if rnd() < 0.35 and a ~= 4 then
			segs[a == 2 and 4 or 2][3] = "alcove"
		end
		if k == 10 then
			segs[5][3] = "cliff"
		end
	end
	return segs
end

local layout = {} -- [k][side] = segments with heights

for k, b in BIOMES do
	local zs = stageZ(k)
	local stageF = Instance.new("Folder")
	stageF.Name = string.format("%02d_%s", k, b.key)
	stageF.Parent = terrainF
	layout[k] = {}

	-- lane floor: checker tiles, a wide light path down the middle
	for zi = 0, STAGE / 10 - 1 do
		for xi = 0, 7 do
			local x0 = -LANE + xi * 8
			local onPath = xi >= 2 and xi <= 5
			local odd = (xi + zi) % 2 == 1
			local hex = onPath and (odd and shade(b.path, 0.94) or b.path) or (odd and b.ground[2] or b.ground[1])
			box(stageF, x0, -2, zs + zi * 10, x0 + 8, 0, zs + zi * 10 + 10, hex, { name = onPath and "Path" or "Floor" })
		end
	end
	-- island body under the stage (two strata, seen from the sides/sky)
	box(stageF, -100, -32, zs, 100, -14, zs + STAGE, shade(b.cliff[2], 0.7), { name = "Island" })
	box(stageF, -100, -14, zs, 100, -2, zs + STAGE, shade(b.cliff[1], 0.85), { name = "Island" })

	for _, side in { -1, 1 } do
		local segs = segmentsFor(k, side)
		layout[k][side] = segs
		for si, sg in segs do
			local z0, z1, kind = sg[1], sg[2], sg[3]
			local cap1 = (si % 2 == 0) and b.ground[1] or b.ground[2]
			local cap2 = (si % 2 == 0) and b.ground[2] or b.ground[1]
			local t1out = 52 + rint(0, 2) * 2
			local t2out = 70 + rint(0, 3) * 2
			local h2 = 24 + rint(0, 3) * 2
			local h3 = 34 + rint(0, 5) * 2
			if k == RIBCAGE_STAGE then
				h2 = 26
			end
			sg.t1out, sg.t2out, sg.h2, sg.h3 = t1out, t2out, h2, h3
			local function X(v)
				return side * v
			end
			local function sbox(xa, xb, ...)
				return math.min(X(xa), X(xb)), math.max(X(xa), X(xb))
			end
			local inner = LANE
			if kind == "alcove" then
				inner = 46
				sg.inner = 46
				-- alcove floor
				local a0, a1 = sbox(LANE, 46)
				box(stageF, a0, -2, z0, a1, 0, z1, b.ground[(si % 2) + 1], { name = "AlcoveFloor" })
			end
			if kind == "waterfall" then
				-- the waterfall model fills x 32..64; cliffs continue behind it
				local a0, a1 = sbox(64, t2out)
				cliff(stageF, a0, a1, z0, z1, 0, h2, b, cap2)
				local c0, c1 = sbox(t2out, 100)
				cliff(stageF, c0, c1, z0, z1, 0, h3, b, cap1)
			else
				local a0, a1 = sbox(inner, t1out)
				cliff(stageF, a0, a1, z0, z1, 0, T1, b, cap1)
				local c0, c1 = sbox(t1out, t2out)
				cliff(stageF, c0, c1, z0, z1, 0, h2, b, cap2)
				local d0, d1 = sbox(t2out, 100)
				cliff(stageF, d0, d1, z0, z1, 0, h3, b, cap1)
				-- flat patches on the tier tops so big plateaus don't read as one flat colour
				for _, tr in { { inner + 2, t1out, T1 }, { t1out, t2out, h2 }, { t2out, 100, h3 } } do
					for _ = 1, rint(1, 3) do
						local w = rint(3, 7) * 2
						local d = rint(3, 6) * 2
						local xa = tr[1] + rnd() * math.max(0, tr[2] - tr[1] - w)
						local za = z0 + rnd() * math.max(0, z1 - z0 - d)
						local p0, p1 = sbox(xa, math.min(xa + w, tr[2]))
						local hex = rnd() < 0.6 and shade(b.ground[1], 0.9) or shade(b.path, 0.97)
						box(stageF, p0, tr[3], za, p1, tr[3] + 0.4, za + d, hex, { name = "Patch" })
					end
				end
				-- grass lip over the lane and rock outcrops on the faces
				local l0, l1 = sbox(inner - 0.8, inner)
				box(stageF, l0, T1 - 1.2, z0, l1, T1, z1, cap1, { name = "Lip" })
				outcrops(stageF, X(inner), z0, z1, 1, T1 - 2, side, b)
				outcrops(stageF, X(t1out), z0, z1, T1 + 1, h2 - 2, side, b)
				if b.drip then
					drips(stageF, X(inner), z0, z1, T1, b.drip, side)
				end
				if b.lava then
					veins(stageF, X(inner), z0, z1, T1, side)
				end
			end
		end
	end

	-- stage zone (for game scripts) + a line across the floor at the gate
	local zone = Instance.new("Part")
	zone.Name = string.format("Stage%02d_%s", k, b.key)
	zone.Anchored = true
	zone.CanCollide = false
	zone.CanQuery = false
	zone.CanTouch = true
	zone.Transparency = 1
	zone.Size = Vector3.new(LANE * 2 + 28, 40, STAGE)
	zone.CFrame = CFrame.new(0, 20, zs + STAGE / 2)
	zone:SetAttribute("StageIndex", k)
	zone:SetAttribute("StageName", b.name)
	zone.Parent = zonesF
	local line = box(zonesF, -LANE, 0, zs + 0.5, LANE, 0.15, zs + 1.7, b.accent, { name = string.format("StageLine%02d", k), mat = "Neon", collide = false, studs = false, shadow = false })
	line:SetAttribute("StageIndex", k)
end

-- Spawn plaza (safe zone) + back wall, and the area under/around the finale
do
	local b = BIOMES[1]
	local f = Instance.new("Folder")
	f.Name = "00_Plaza"
	f.Parent = terrainF
	for zi = 0, PLAZA / 10 - 1 do
		for xi = 0, 7 do
			local x0 = -LANE + xi * 8
			local hex = ((xi + zi) % 2 == 0) and "#f4f1e6" or "#e3dfcf"
			box(f, x0, -2, zi * 10, x0 + 8, 0, zi * 10 + 10, hex, { name = "PlazaTile" })
		end
	end
	box(f, -100, -32, -40, 100, -14, PLAZA, shade(b.cliff[2], 0.7), { name = "Island" })
	box(f, -100, -14, -40, 100, -2, PLAZA, shade(b.cliff[1], 0.85), { name = "Island" })
	for _, side in { -1, 1 } do
		local function sb(xa, xb)
			return math.min(side * xa, side * xb), math.max(side * xa, side * xb)
		end
		local a0, a1 = sb(LANE, 54)
		cliff(f, a0, a1, 0, PLAZA, 0, T1, b, b.ground[1])
		local c0, c1 = sb(54, 72)
		cliff(f, c0, c1, 0, PLAZA, 0, 26, b, b.ground[2])
		local d0, d1 = sb(72, 100)
		cliff(f, d0, d1, 0, PLAZA, 0, 38, b, b.ground[1])
	end
	-- back wall behind spawn: stepped
	cliff(f, -LANE, LANE, -10, 0, 0, 18, b, b.ground[2])
	cliff(f, -100, 100, -24, -10, 0, 30, b, b.ground[1])
	cliff(f, -100, 100, -40, -24, 0, 40, b, b.ground[2])
	-- red safe-zone stripe just before the first gate
	box(f, -LANE, 0, PLAZA - 3, LANE, 0.2, PLAZA - 1.5, "#ff3b3b", { name = "SafeZoneLine", mat = "Neon", collide = false, studs = false, shadow = false })

	-- finale ground + closing walls
	local s = BIOMES[10]
	local e = Instance.new("Folder")
	e.Name = "11_Finale"
	e.Parent = terrainF
	box(e, -100, -2, ZEND, 100, 0, ZEND + 50, s.path, { name = "FinaleFloor" })
	box(e, -100, -32, ZEND, 100, -14, ZEND + 50, shade(s.cliff[2], 0.7), { name = "Island" })
	box(e, -100, -14, ZEND, 100, -2, ZEND + 50, shade(s.cliff[1], 0.85), { name = "Island" })
	for _, side in { -1, 1 } do
		local x0, x1 = math.min(side * 60, side * 100), math.max(side * 60, side * 100)
		cliff(e, x0, x1, ZEND, ZEND + 50, 0, 40, s, s.ground[1])
	end
	cliff(e, -100, 100, ZEND + 16, ZEND + 50, 0, 46, s, s.ground[2])
end

-- Invisible barriers: keep players in the hallway (they can't climb the cliffs)
for _, side in { -1, 1 } do
	box(barrierF, side * 32.6, T1, -10, side * 33.6, 160, ZEND + 30, "#ffffff", { name = "Barrier", tr = 1, studs = false, hidden = true, shadow = false })
end
box(barrierF, -LANE, 0, -1, LANE, 160, 0, "#ffffff", { name = "Barrier", tr = 1, studs = false, hidden = true, shadow = false })

---------------------------------------------------------------------------
-- Dressing
---------------------------------------------------------------------------

local function isRowFiller(id)
	return id:find("Fence") or id:find("Post")
end

local function faceYaw(side, jitter)
	-- face the lane, angled a little toward the approaching player (-Z)
	return side * (math.pi / 2 - 0.3) + (jitter or 0) * (rnd() - 0.5)
end

for k, b in BIOMES do
	local zs = stageZ(k)
	local f = Instance.new("Folder")
	f.Name = string.format("%02d_%s", k, b.key)
	f.Parent = decoF

	local loose = {}
	for _, id in b.filler do
		if not isRowFiller(id) then
			table.insert(loose, id)
		end
	end
	local rowId = nil
	for _, id in b.filler do
		if isRowFiller(id) then
			rowId = id
		end
	end
	if #loose == 0 then
		loose = b.filler
	end
	local decorUsed = {}
	local nextScenery = bag(b.scenery)
	local nextDecor = bag(b.decor)
	local nextLoose = bag(loose)

	local function anyFiller()
		return nextLoose()
	end
	local function scatterFiller(x, y, z, side)
		local id = anyFiller()
		local yaw = rint(0, 3) * math.pi / 2 + (rnd() - 0.5) * 0.6
		return place(f, id, x, y, z, yaw)
	end

	for _, side in { -1, 1 } do
		local segs = layout[k][side]
		local rowSegs = {}
		if rowId then
			rowSegs[rint(2, #segs)] = true
		end

		for si, sg in segs do
			local z0, z1, kind = sg[1], sg[2], sg[3]
			local gateZone = si == 1

			-- 1) lane edge, on the floor hugging the wall
			if kind == "cliff" then
				if rowSegs[si] and rowId then
					local e = getModel(rowId)
					if e then
						local step = e.w + 0.2
						local zz = math.max(z0, zs + 14) + step / 2
						while zz + step / 2 < z1 - 1 do
							place(f, rowId, side * (LANE - e.d / 2 - 0.4), 0, zz, math.pi / 2)
							zz += step
						end
					end
				else
					local zz = math.max(z0, zs + 13) + rnd() * 4
					while zz < z1 - 3 do
						local id = anyFiller()
						local e = getModel(id)
						if e then
							local yaw = rint(0, 3) * math.pi / 2 + (rnd() - 0.5) * 0.5
							local hx, hz = footprint(e, yaw)
							place(f, id, side * (LANE - hx - 0.3), 0, zz + hz, yaw)
							zz += hz * 2 + rint(9, 18)
						else
							zz += 8
						end
					end
				end
			elseif kind == "alcove" then
				-- a decoration on show in the alcove, filler at its corners
				local pool = b.decor
				local id = nil
				for _, cand in pool do
					if not decorUsed[cand] then
						id = cand
						break
					end
				end
				id = id or pick(pool)
				decorUsed[id] = true
				local e = getModel(id)
				if e then
					local yaw = side * math.pi / 2
					local hx, hz = footprint(e, yaw)
					local zc = (z0 + z1) / 2
					local xc = side * math.max(LANE + 7, 46 - hx - 0.6)
					place(f, id, xc, 0, zc, yaw)
					if hz < 11 then
						scatterFiller(side * 43, 0, z0 + 3, side)
						scatterFiller(side * 43, 0, z1 - 3, side)
					end
				end
			end

			-- 2) first cliff tier (y = 14): scenery and decorations facing the lane
			local inner = sg.inner or LANE
			if kind ~= "waterfall" then
				local mid = (inner + sg.t1out) / 2
				local width = sg.t1out - inner
				local zz = z0 + (gateZone and 14 or 1)
				if k == RIBCAGE_STAGE or kind == "alcove" or width < 12 then
					-- only small things (rib tips land here in the Badlands)
					zz = z0 + 3
					while zz < z1 - 3 do
						scatterFiller(side * mid, T1, zz, side)
						zz += rint(12, 18)
					end
				else
					local first = true
					while zz < z1 - 4 do
						local id
						if first and #b.animDecor > 0 and si == 3 and side == 1 then
							id = pick(b.animDecor)
						elseif rnd() < 0.7 then
							id = nextScenery()
						else
							id = nextDecor()
						end
						first = false
						local e = getModel(id)
						if not e then
							break
						end
						local yaw = faceYaw(side, 0.3)
						local hx, hz = footprint(e, yaw)
						if zz + hz * 2 > z1 + 6 then
							-- doesn't fit: fill with filler instead
							scatterFiller(side * mid, T1, zz + 3, side)
							break
						end
						place(f, id, side * math.max(mid, inner + hx * 0.75), T1, zz + hz, yaw)
						zz += hz * 2 + rint(4, 9)
					end
				end
			end

			-- 3) second / third tiers: one big piece per segment for a layered backdrop
			if kind ~= "waterfall" and rnd() < 0.6 then
				local id = nextScenery()
				local e = getModel(id)
				if e then
					local yaw = faceYaw(side, 0.8)
					place(f, id, side * (sg.t1out + sg.t2out) / 2, sg.h2, (z0 + z1) / 2 + (rnd() - 0.5) * 6, yaw)
				end
			end
			if rnd() < 0.45 then
				local id = nextScenery()
				local e = getModel(id)
				if e then
					place(f, id, side * (sg.t2out + 12 + rnd() * 8), sg.h3, (z0 + z1) / 2 + (rnd() - 0.5) * 8, faceYaw(side, 1.2))
				end
			end
		end
	end
end

---------------------------------------------------------------------------
-- Landmarks: gates, waterfalls, ribcage, finale
---------------------------------------------------------------------------

local function signText(sign, text, accent)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "StageName"
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0
	gui.Parent = sign
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = roblox.UDim2.new(0.94, 0, 0.84, 0)
	t.Position = roblox.UDim2.new(0.03, 0, 0.08, 0)
	t.Text = text
	t.TextScaled = true
	t.FontFace = roblox.Font.fromEnum(Enum.Font.FredokaOne)
	t.TextColor3 = Color3.new(1, 1, 1)
	t.Parent = gui
	local s = Instance.new("UIStroke")
	s.Thickness = 5
	s.Color = color("#1c1c28")
	s.Parent = t
	local g = Instance.new("UIGradient")
	g.Color = roblox.ColorSequence.new(Color3.new(1, 1, 1), color(accent))
	g.Rotation = 90
	g.Parent = t
end

for k, b in BIOMES do
	local m = place(landF, b.gate, 0, 0, stageZ(k) + 6, 0, false)
	if m then
		m.Name = string.format("Gate%02d_%s", k, b.key)
		for _, d in m:GetDescendants() do
			if d:IsA("BasePart") and d.Name == "Sign" then
				signText(d, b.name, b.accent)
			end
		end
	end
end

for _, w in WATERFALLS do
	local zc = stageZ(w.stage) + (w.z0 + w.z1) / 2
	place(landF, w.id, w.side * (LANE + 16), 0, zc, w.side * math.pi / 2, false)
end

place(landF, "MapBadRibcage", 0, 0, stageZ(RIBCAGE_STAGE) + 74, 0, false)
place(landF, "MapStarFinale", 0, 0, ZEND + 22, 0, false)

---------------------------------------------------------------------------
-- Biome ambience: a client script that blends lighting per stage
---------------------------------------------------------------------------

local AMBIENCE_SRC = [==[
-- Blends the sky haze / colour tint as the player runs through the stages.
-- Delete this script if your game controls Lighting itself.
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local map = script.Parent
local origin = map:WaitForChild("MapOrigin")

local PLAZA, STAGE = %d, %d
local LOOKS = {
%s
}

local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
if not atmo then
	atmo = Instance.new("Atmosphere")
	atmo.Parent = Lighting
end
local cc = Lighting:FindFirstChild("BiomeTint")
if not cc then
	cc = Instance.new("ColorCorrectionEffect")
	cc.Name = "BiomeTint"
	cc.Parent = Lighting
end

local function look(z)
	local f = (z - PLAZA) / STAGE + 0.5 -- blend across each gate
	local i = math.clamp(math.floor(f), 1, #LOOKS)
	local j = math.clamp(i + 1, 1, #LOOKS)
	local t = math.clamp((f - math.floor(f) - 0.8) / 0.2, 0, 1)
	if f < 1 then i, j, t = 1, 1, 0 end
	return LOOKS[i], LOOKS[j], t
end

RunService.RenderStepped:Connect(function(dt)
	local cam = workspace.CurrentCamera
	if not cam then return end
	local z = origin.CFrame:PointToObjectSpace(cam.CFrame.Position).Z
	local a, b, t = look(z)
	local k = math.min(1, dt * 2.5)
	local function mixc(c1, c2) return c1:Lerp(c2, t) end
	atmo.Color = atmo.Color:Lerp(mixc(a.color, b.color), k)
	atmo.Decay = atmo.Decay:Lerp(mixc(a.decay, b.decay), k)
	atmo.Density = atmo.Density + ((a.density + (b.density - a.density) * t) - atmo.Density) * k
	atmo.Haze = atmo.Haze + ((a.haze + (b.haze - a.haze) * t) - atmo.Haze) * k
	cc.TintColor = cc.TintColor:Lerp(mixc(a.tint, b.tint), k)
end)
]==]

local LOOKS = {
	{ "#cfe9ff", "#8fb7e0", 0.22, 0.3, "#ffffff" }, -- Sunny Farm
	{ "#ffd6f0", "#d78fe0", 0.26, 0.6, "#fff2fb" }, -- Bunny Meadow
	{ "#ffe2b8", "#e0a46b", 0.28, 0.9, "#fff4e4" }, -- Harvest Fields
	{ "#cfeccf", "#6fa77a", 0.3, 1.2, "#f2fff2" }, -- Thorny Woods
	{ "#d6ffcf", "#5fb36a", 0.32, 1.4, "#f2fff0" }, -- Snap-Jaw Jungle
	{ "#ffefc8", "#e6b46b", 0.26, 1.0, "#fff8e8" }, -- Sandy Savanna
	{ "#c8e8dc", "#6c8f86", 0.42, 2.4, "#eefaf5" }, -- Misty Swamp
	{ "#fff1c2", "#e8bd5a", 0.25, 0.8, "#fffbe8" }, -- Honey Hills
	{ "#ffc9b0", "#b0503a", 0.34, 1.8, "#fff0ea" }, -- Bramble Badlands
	{ "#d8d2ff", "#6a5cc8", 0.32, 1.4, "#f4f0ff" }, -- Starlight Ruins
}
local function c3(hex)
	local c = color(hex)
	return string.format("Color3.new(%.3f, %.3f, %.3f)", c.R, c.G, c.B)
end
local lookLines = {}
for i, l in LOOKS do
	table.insert(lookLines, string.format("\t{ color = %s, decay = %s, density = %.2f, haze = %.1f, tint = %s }, -- %s", c3(l[1]), c3(l[2]), l[3], l[4], c3(l[5]), BIOMES[i].name))
end
local ambienceSrc = string.format(AMBIENCE_SRC, PLAZA, STAGE, table.concat(lookLines, "\n"))
assert(pcall(luau.compile, ambienceSrc), "ambience script does not compile")
local amb = Instance.new("Script")
amb.Name = "BiomeAmbience"
amb.RunContext = Enum.RunContext.Client
amb.Source = ambienceSrc
amb.Parent = map

---------------------------------------------------------------------------
-- Write
---------------------------------------------------------------------------

local count = 0
for _, d in map:GetDescendants() do
	if d:IsA("BasePart") then
		count += 1
	end
end

fs.writeFile("out/GardenMap.rbxm", roblox.serializeModel({ map }))

local game = Instance.new("DataModel")
local workspace = game:GetService("Workspace")
local lighting = game:GetService("Lighting")
map.Parent = workspace

local spawn = Instance.new("SpawnLocation")
spawn.Name = "SpawnLocation"
spawn.Anchored = true
spawn.Size = Vector3.new(10, 1, 10)
spawn.CFrame = CFrame.new(0, 0.5, 22) * CFrame.Angles(0, math.pi, 0)
spawn.Color = color("#7ee0ff")
spawn.Material = Enum.Material.Plastic
spawn.TopSurface = Enum.SurfaceType.Studs
spawn.Duration = 0
spawn.Parent = workspace
table.insert(previewParts, { size = { 10, 1, 10 }, cf = cfArr(spawn.CFrame), color = "#7ee0ff", mat = "Plastic", tr = 0 })

pcall(function()
	workspace.StreamingEnabled = true
end)
lighting.ClockTime = 14
lighting.GeographicLatitude = 35
lighting.Brightness = 3
lighting.Ambient = color("#4a4a55")
lighting.OutdoorAmbient = color("#8f93a3")
lighting.EnvironmentDiffuseScale = 0.5
lighting.EnvironmentSpecularScale = 0.25
lighting.ShadowSoftness = 0.25
lighting.GlobalShadows = true
pcall(function()
	lighting.Technology = Enum.Technology.Future
end)
local bloom = Instance.new("BloomEffect")
bloom.Intensity = 0.55
bloom.Size = 18
bloom.Threshold = 1.8
bloom.Parent = lighting
local cc = Instance.new("ColorCorrectionEffect")
cc.Saturation = 0.12
cc.Contrast = 0.06
cc.Brightness = 0.01
cc.Parent = lighting
local atmo = Instance.new("Atmosphere")
atmo.Density = 0.22
atmo.Offset = 0.1
atmo.Haze = 0.3
atmo.Glare = 0
atmo.Color = color("#cfe9ff")
atmo.Decay = color("#8fb7e0")
atmo.Parent = lighting
local sky = Instance.new("Sky")
sky.SunAngularSize = 14
sky.Parent = lighting
pcall(function()
	game:GetService("StarterPlayer").GameSettingsAvatar = Enum.GameAvatarType.R15
end)
fs.writeFile("out/GardenMap.rbxl", roblox.serializePlace(game))

-- previewer scene + named cameras
local cams = {
	start = { 0, 9, 8, 0, 6, 80 },
	sky = { 230, 260, -120, 0, 0, 520 },
	skyfar = { 420, 520, -260, 0, 0, 760 },
}
for k, b in BIOMES do
	local zs = stageZ(k)
	cams["s" .. k] = { 0, 10, zs - 6, 0, 8, zs + 70 } -- run view entering the stage
	cams["a" .. k] = { 90, 75, zs - 30, 0, 6, zs + 70 } -- aerial
end
cams.ribs = { 0, 6, stageZ(RIBCAGE_STAGE) + 20, 0, 22, stageZ(RIBCAGE_STAGE) + 110 }
cams.falls1 = { -20, 10, stageZ(1) + 40, 40, 14, stageZ(1) + 80 }
cams.falls4 = { 20, 10, stageZ(4) + 40, -40, 14, stageZ(4) + 80 }
cams.finale = { 0, 10, ZEND - 70, 0, 22, ZEND + 10 }
fs.writeFile("out/preview/_map.json", serde.encode("json", { instances = previewInstances, parts = previewParts, cams = cams, length = ZEND + 50 }))

print(("Wrote out/GardenMap.rbxm + out/GardenMap.rbxl: %d parts, %d models placed, length %d studs"):format(count, #previewInstances, ZEND + 50))
if #missing > 0 then
	print("MISSING (build them first): " .. table.concat(missing, ", "))
end
