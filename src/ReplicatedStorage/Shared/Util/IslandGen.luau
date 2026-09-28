--!strict
--[[
	SCRIPT NAME:  IslandGen
	SCRIPT TYPE:  ModuleScript (shared utility, pure math)
	WHERE:        ReplicatedStorage/Shared/Util/IslandGen
	DEPENDENCIES: Shared.Config.{IslandConfig, ResourceConfig}

	Deterministic island generation from saved data:
		{ Seed, Theme, Shape, Chunks = { ["cx_cz"] = true }, Paint = { ["px_pz"] = "Material" } }

	  * GenerateStarter  grows an organic, connected starter shape from the
	                     centre by priority (shape field + seeded noise).
	  * Sampler          height, surface material and distance-to-coast at
	                     any island-local point: smooth beaches, wobbly
	                     coastline (rounded by an outward offset + noise),
	                     theme hills, a flat build plaza, painted cells.
	  * NodeSpots        where trees / rocks / bushes grow for every chunk.
	  * Expansion        which chunks can be bought next and their price.

	Used by the server (terrain writer, validation, spawning) and the client
	(build preview, expansion outlines, creator preview) so both agree.
]]

local Config = script.Parent.Parent.Config
local IslandConfig = require(Config.IslandConfig)

local IslandGen = {}

local C = IslandConfig.ChunkSize
local R = IslandConfig.GridRadius
local HALF = C / 2
local SEARCH = 3 -- chunks searched around a point for the coast
local OUTWARD = 6 -- land extends this far past owned chunk edges (rounds convex corners)

export type IslandData = {
	Seed: number,
	Theme: string,
	Shape: string?,
	Chunks: { [string]: boolean },
	Paint: { [string]: string }?,
}

export type Sample = {
	Height: number, -- studs above sea level
	Material: string, -- Enum.Material name
	Shore: number, -- > 0 on land (noisy distance inland from the waterline)
	Coast: number, -- raw distance to the edge of owned chunks (negative in water)
	Owned: boolean, -- inside an owned chunk
}

---------------------------------------------------------------------------
-- Keys
---------------------------------------------------------------------------

function IslandGen.Key(cx: number, cz: number): string
	return cx .. "_" .. cz
end

function IslandGen.ParseKey(key: string): (number?, number?)
	local a, b = string.match(key, "^(%-?%d+)_(%-?%d+)$")
	if not a or not b then
		return nil, nil
	end
	return tonumber(a), tonumber(b)
end

-- Chunk containing an island-local XZ point.
function IslandGen.ChunkOf(x: number, z: number): (number, number)
	return math.floor(x / C + 0.5), math.floor(z / C + 0.5)
end

function IslandGen.ChunkCenter(cx: number, cz: number): Vector2
	return Vector2.new(cx * C, cz * C)
end

function IslandGen.InGrid(cx: number, cz: number): boolean
	return math.abs(cx) <= R and math.abs(cz) <= R
end

local function intKey(cx: number, cz: number): number
	return (cx + 64) * 256 + (cz + 64)
end

function IslandGen.CountChunks(chunks: { [string]: boolean }): number
	local count = 0
	for _, owned in chunks do
		if owned then
			count += 1
		end
	end
	return count
end

---------------------------------------------------------------------------
-- Noise helpers (math.noise is Perlin, ~[-0.5, 0.5]; offsets keep it off integer lattice points)
---------------------------------------------------------------------------

local function seedOffset(seed: number, salt: number): number
	return ((seed * 0.6180339887 + salt * 13.37) % 997) + 0.31
end

local function noise(x: number, z: number, scale: number, seed: number, salt: number): number
	return math.noise(x / scale + 0.123, z / scale + 0.457, seedOffset(seed, salt))
end

local function smoothstep(edge0: number, edge1: number, value: number): number
	local t = math.clamp((value - edge0) / (edge1 - edge0), 0, 1)
	return t * t * (3 - 2 * t)
end

---------------------------------------------------------------------------
-- Starter shape
---------------------------------------------------------------------------

local SHAPE_FIELDS: { [string]: (x: number, z: number) -> number } = {
	Round = function(x, z)
		return -math.sqrt(x * x + z * z)
	end,
	Crescent = function(x, z)
		local r = math.sqrt(x * x + z * z)
		local bite = math.sqrt(x * x + (z + 4.2) ^ 2)
		return -math.abs(r - 3.8) * 1.4 - math.max(0, 3.8 - bite) * 3
	end,
	Twin = function(x, z)
		local a = math.sqrt((x - 4.6) ^ 2 + z * z)
		local b = math.sqrt((x + 4.6) ^ 2 + z * z)
		return -math.min(a, b) * 1.6 - math.abs(z) * 0.8
	end,
	Long = function(x, z)
		return -(math.abs(x) * 0.45 + math.abs(z) * 2.2)
	end,
	Wild = function(x, z)
		return -math.sqrt(x * x + z * z) * 0.55
	end,
}

-- Grows a connected chunk set from the centre. Deterministic for (seed, shape, count).
function IslandGen.GenerateStarter(seed: number, shape: string, count: number?): { [string]: boolean }
	local target = count or IslandConfig.StarterChunks
	local field = SHAPE_FIELDS[shape] or SHAPE_FIELDS.Round
	local wild = if shape == "Wild" then 3.2 else 1.3
	local chunks: { [string]: boolean } = {}
	local frontier: { [string]: { X: number, Z: number, Score: number } } = {}
	local owned = 0

	local function score(cx: number, cz: number): number
		return field(cx, cz) + noise(cx * 7.1, cz * 7.1, 9, seed, 1) * wild * 2
	end
	local function add(cx: number, cz: number)
		local key = IslandGen.Key(cx, cz)
		if chunks[key] or not IslandGen.InGrid(cx, cz) then
			return
		end
		chunks[key] = true
		frontier[key] = nil
		owned += 1
		for _, offset in { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
			local nx, nz = cx + offset[1], cz + offset[2]
			local nkey = IslandGen.Key(nx, nz)
			if not chunks[nkey] and not frontier[nkey] and IslandGen.InGrid(nx, nz) then
				frontier[nkey] = { X = nx, Z = nz, Score = score(nx, nz) }
			end
		end
	end

	-- The plaza is always land so spawn + landmarks fit on every shape.
	local plaza = math.ceil(IslandConfig.PlazaRadius)
	for cx = -plaza, plaza do
		for cz = -plaza, plaza do
			if math.sqrt(cx * cx + cz * cz) <= IslandConfig.PlazaRadius then
				add(cx, cz)
			end
		end
	end

	while owned < target do
		local bestKey, best = nil, nil
		for key, cell in frontier do
			if best == nil or cell.Score > best.Score or (cell.Score == best.Score and key < (bestKey :: string)) then
				bestKey, best = key, cell
			end
		end
		if not best then
			break
		end
		add(best.X, best.Z)
	end

	-- Fill pockets: water cells mostly surrounded by land become land.
	local changed = true
	while changed do
		changed = false
		for key, cell in table.clone(frontier) do
			local neighbours = 0
			for _, offset in { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
				if chunks[IslandGen.Key(cell.X + offset[1], cell.Z + offset[2])] then
					neighbours += 1
				end
			end
			if neighbours >= 3 and frontier[key] then
				add(cell.X, cell.Z)
				changed = true
			end
		end
	end
	return chunks
end

---------------------------------------------------------------------------
-- Sampler
---------------------------------------------------------------------------

export type Sampler = {
	Data: IslandData,
	Theme: any,
	Owned: { [number]: boolean },
	Sample: (self: Sampler, x: number, z: number) -> Sample,
	IsOwnedChunk: (self: Sampler, cx: number, cz: number) -> boolean,
}

local SamplerClass = {}
SamplerClass.__index = SamplerClass

function IslandGen.NewSampler(data: IslandData): Sampler
	local owned: { [number]: boolean } = {}
	for key, value in data.Chunks do
		if value then
			local cx, cz = IslandGen.ParseKey(key)
			if cx and cz and IslandGen.InGrid(cx, cz) then
				owned[intKey(cx, cz)] = true
			end
		end
	end
	local theme = IslandConfig.Themes[data.Theme] or IslandConfig.Themes[IslandConfig.DefaultTheme]
	return setmetatable({ Data = data, Theme = theme, Owned = owned }, SamplerClass) :: any
end

function SamplerClass.IsOwnedChunk(self: Sampler, cx: number, cz: number): boolean
	return self.Owned[intKey(cx, cz)] == true
end

-- Signed distance (studs) from (x, z) to the edge of the owned-chunk union.
local function coastDistance(sampler: Sampler, x: number, z: number): (number, boolean)
	local cx, cz = IslandGen.ChunkOf(x, z)
	local inside = sampler.Owned[intKey(cx, cz)] == true
	local best = SEARCH * C
	for i = cx - SEARCH, cx + SEARCH do
		for j = cz - SEARCH, cz + SEARCH do
			local isOwned = sampler.Owned[intKey(i, j)] == true
			if isOwned ~= inside then
				local dx = math.max(math.abs(x - i * C) - HALF, 0)
				local dz = math.max(math.abs(z - j * C) - HALF, 0)
				local distance = math.sqrt(dx * dx + dz * dz)
				if distance < best then
					best = distance
				end
			end
		end
	end
	return if inside then best else -best, inside
end

function SamplerClass.Sample(self: Sampler, x: number, z: number): Sample
	local data = self.Data
	local theme = self.Theme
	local seed = data.Seed
	local coast, owned = coastDistance(self, x, z)
	local shore = coast + OUTWARD + noise(x, z, 22, seed, 2) * IslandConfig.CoastNoise * 2

	local height: number
	local beach = IslandConfig.BeachWidth
	if shore <= 0 then
		height = -1 - math.min(13, -shore * 0.55)
	elseif shore < beach then
		height = -1 + (IslandConfig.LandHeight + 1) * smoothstep(0, beach, shore)
	else
		local centerDistance = math.sqrt(x * x + z * z)
		local flatten = smoothstep(IslandConfig.FlattenRadius, IslandConfig.FlattenRadius + 24, centerDistance)
		local inland = smoothstep(beach, beach + 26, shore)
		local hillNoise = math.clamp(noise(x, z, 64, seed, 3) * 1.7 + 0.2, 0, 1)
		local bumps = noise(x, z, 17, seed, 4) * 0.8
		height = IslandConfig.LandHeight + (theme.HillAmp * hillNoise + bumps) * inland * flatten
	end

	local material: string
	if height < 0.3 then
		material = if shore > 0 then theme.Beach else theme.Seabed
	elseif shore < beach - 1 then
		material = theme.Beach
	else
		local lift = height - IslandConfig.LandHeight
		if lift > theme.HillAmp * 0.62 and noise(x, z, 11, seed, 5) > -0.05 then
			material = theme.Cliff
		elseif noise(x, z, 26, seed, 6) > 0.22 then
			material = theme.Alt
		else
			material = theme.Ground
		end
		local paint = data.Paint
		if paint then
			local cell = IslandConfig.PaintCellSize
			local painted = paint[math.floor(x / cell) .. "_" .. math.floor(z / cell)]
			if painted and IslandConfig.Paint[painted] then
				material = painted
			end
		end
	end

	return { Height = height, Material = material, Shore = shore, Coast = coast, Owned = owned }
end

-- Can a building footprint point go here? (owned land, far enough from the water)
function IslandGen.IsBuildable(sampler: Sampler, x: number, z: number): boolean
	local cx, cz = IslandGen.ChunkOf(x, z)
	if not sampler:IsOwnedChunk(cx, cz) then
		return false
	end
	local sample = sampler:Sample(x, z)
	return sample.Coast >= IslandConfig.BuildCoastDistance and sample.Height > 0.8
end

-- Is this point (roughly) water next to this island? Used by fishing.
function IslandGen.IsWater(sampler: Sampler, x: number, z: number): boolean
	return sampler:Sample(x, z).Height < -0.4
end

---------------------------------------------------------------------------
-- Resources
---------------------------------------------------------------------------

export type Spot = { Id: string, Type: string, Position: Vector2, Yaw: number }

local function seedFor(seed: number, text: string): number
	local value = seed % 2147483647
	for index = 1, #text do
		value = (value * 31 + string.byte(text, index)) % 2147483647
	end
	return value
end

local function weightedPick(random: Random, weights: { [string]: number }): string?
	local names = {}
	local total = 0
	for name, weight in weights do
		if weight > 0 then
			table.insert(names, name)
			total += weight
		end
	end
	table.sort(names)
	if total <= 0 then
		return nil
	end
	local roll = random:NextNumber(0, total)
	for _, name in names do
		roll -= weights[name]
		if roll <= 0 then
			return name
		end
	end
	return names[#names]
end

-- Resource weights for a chunk: the theme's mix, plus rarer ores/trees far from home.
function IslandGen.ChunkWeights(themeId: string, cx: number, cz: number): { [string]: number }
	local theme = IslandConfig.Themes[themeId] or IslandConfig.Themes[IslandConfig.DefaultTheme]
	local weights = table.clone(theme.Nodes)
	local distance = math.sqrt(cx * cx + cz * cz)
	if distance >= 6 then
		weights.IronRock = (weights.IronRock or 0) + 1.2
	end
	if distance >= 9 then
		weights.CrystalRock = (weights.CrystalRock or 0) + 0.7
		weights.AncientTree = (weights.AncientTree or 0) + 0.6
	end
	return weights
end

-- Resource spots of one chunk (only those that are valid land for this island right now).
function IslandGen.ChunkSpots(sampler: Sampler, cx: number, cz: number): { Spot }
	local data = sampler.Data
	local key = IslandGen.Key(cx, cz)
	local random = Random.new(seedFor(data.Seed, key))
	local roll = random:NextNumber()
	local count = if roll < 0.3 then 0 elseif roll < 0.78 then 1 else 2
	local weights = IslandGen.ChunkWeights(data.Theme, cx, cz)
	local spots: { Spot } = {}
	local keepClear = IslandConfig.StarterLayout.KeepClearRadius
	for index = 1, count do
		local nodeType = weightedPick(random, weights)
		-- Two candidate sub-cells so the pair never overlaps.
		local offsetX = random:NextNumber(-HALF + 3, HALF - 3)
		local offsetZ = if index == 1 then random:NextNumber(-HALF + 3, -1) else random:NextNumber(1, HALF - 3)
		local position = Vector2.new(cx * C + offsetX, cz * C + offsetZ)
		local yaw = random:NextNumber(0, 360)
		if nodeType and position.Magnitude > keepClear then
			local sample = sampler:Sample(position.X, position.Y)
			if sample.Owned and sample.Height > 1.2 and sample.Coast > 2 then
				table.insert(spots, { Id = key .. "#" .. index, Type = nodeType, Position = position, Yaw = yaw })
			end
		end
	end
	return spots
end

-- Every resource spot on the island (skipping ones the owner removed).
function IslandGen.AllSpots(sampler: Sampler, removed: { [string]: boolean }?): { Spot }
	local spots = {}
	for key, value in sampler.Data.Chunks do
		if value then
			local cx, cz = IslandGen.ParseKey(key)
			if cx and cz then
				for _, spot in IslandGen.ChunkSpots(sampler, cx, cz) do
					if not (removed and removed[spot.Id]) then
						table.insert(spots, spot)
					end
				end
			end
		end
	end
	return spots
end

export type Deco = { Kind: string, Position: Vector2, Yaw: number, Scale: number }

-- Purely decorative scatter (flowers, tufts, shells...) for one chunk.
function IslandGen.ChunkDeco(sampler: Sampler, cx: number, cz: number): { Deco }
	local data = sampler.Data
	local theme = sampler.Theme
	local random = Random.new(seedFor(data.Seed, "deco" .. IslandGen.Key(cx, cz)))
	local list: { Deco } = {}
	for _ = 1, random:NextInteger(1, 3) do
		local kind = theme.Deco[random:NextInteger(1, #theme.Deco)]
		local position = Vector2.new(cx * C + random:NextNumber(-HALF, HALF), cz * C + random:NextNumber(-HALF, HALF))
		local sample = sampler:Sample(position.X, position.Y)
		local shellsOnBeach = kind == "Shells"
		local ok = if shellsOnBeach then sample.Height > 0.2 and sample.Material == theme.Beach else sample.Height > 1.5 and sample.Material ~= theme.Beach
		if ok then
			table.insert(list, { Kind = kind, Position = position, Yaw = random:NextNumber(0, 360), Scale = random:NextNumber(0.8, 1.25) })
		end
	end
	return list
end

---------------------------------------------------------------------------
-- Expansion
---------------------------------------------------------------------------

-- Water chunks touching owned land (4-neighbourhood), inside the grid.
function IslandGen.ExpansionCandidates(chunks: { [string]: boolean }): { { X: number, Z: number } }
	local result = {}
	local seen: { [string]: boolean } = {}
	for key, value in chunks do
		if value then
			local cx, cz = IslandGen.ParseKey(key)
			if cx and cz then
				for _, offset in { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
					local nx, nz = cx + offset[1], cz + offset[2]
					local nkey = IslandGen.Key(nx, nz)
					if not chunks[nkey] and not seen[nkey] and IslandGen.InGrid(nx, nz) then
						seen[nkey] = true
						table.insert(result, { X = nx, Z = nz })
					end
				end
			end
		end
	end
	return result
end

function IslandGen.IsAdjacent(chunks: { [string]: boolean }, cx: number, cz: number): boolean
	for _, offset in { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
		if chunks[IslandGen.Key(cx + offset[1], cz + offset[2])] then
			return true
		end
	end
	return false
end

function IslandGen.ExpansionCost(ownedCount: number): number
	local expansion = IslandConfig.Expansion
	local extra = math.max(0, ownedCount - IslandConfig.StarterChunks)
	local cost = expansion.BaseCost + expansion.Linear * extra + expansion.Quadratic * extra * extra
	return math.floor(cost / 10 + 0.5) * 10
end

function IslandGen.MaxChunks(islandLevel: number): number
	local expansion = IslandConfig.Expansion
	return math.min(expansion.MaxChunks, IslandConfig.StarterChunks + math.max(0, islandLevel - 1) * expansion.ChunksPerIslandLevel)
end

return IslandGen
