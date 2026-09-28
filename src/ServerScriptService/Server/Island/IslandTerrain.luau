--[[
	SCRIPT NAME:  IslandTerrain
	SCRIPT TYPE:  ModuleScript (server)
	WHERE:        ServerScriptService/Server/Island/IslandTerrain
	DEPENDENCIES: Shared.Config.{IslandConfig, GameConfig}, Shared.Util.IslandGen

	Writes an island's smooth terrain from Shared/Util/IslandGen samples with
	ONE Terrain:WriteVoxels call per region (fast, no per-voxel API calls):

	  * above sea level: land voxels with fractional occupancy, so slopes and
	    beaches are smooth, and a surface material from the theme / paint,
	  * below sea level: seabed or water,
	  * Write(..., previousSampler, alpha) blends from the old island to the
	    new one — used for the "land rises out of the sea" expansion effect.

	Island origins sit on the 4-stud voxel grid at sea level (IslandLayout),
	so voxel layers line up exactly with the water surface.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local IslandConfig = require(Shared.Config.IslandConfig)
local GameConfig = require(Shared.Config.GameConfig)

local IslandTerrain = {}

local RES = 4
local Y_MIN = -16
local Y_MAX = 36
local SUBSURFACE: { [string]: string } = {
	Sand = "Sand",
	Salt = "Sand",
	Sandstone = "Sandstone",
	Snow = "Rock",
	Rock = "Rock",
	Slate = "Slate",
}

local materialCache: { [string]: Enum.Material } = {}
local function materialOf(name: string): Enum.Material
	local material = materialCache[name]
	if not material then
		local ok, value = pcall(function()
			return (Enum.Material :: any)[name]
		end)
		material = if ok and value then value else Enum.Material.Grass
		materialCache[name] = material
	end
	return material
end

local function alignDown(value: number): number
	return math.floor(value / RES) * RES
end

local function alignUp(value: number): number
	return math.ceil(value / RES) * RES
end

-- Island-local bounds of the whole island grid (plus a margin for beaches).
function IslandTerrain.FullBounds(): (number, number, number, number)
	local extent = (IslandConfig.GridRadius + 1.5) * IslandConfig.ChunkSize
	return -extent, extent, -extent, extent
end

-- Island-local bounds around one chunk (neighbours' coasts change too).
function IslandTerrain.ChunkBounds(cx: number, cz: number, margin: number?): (number, number, number, number)
	local size = IslandConfig.ChunkSize
	local reach = size * (0.5 + (margin or 3))
	return cx * size - reach, cx * size + reach, cz * size - reach, cz * size + reach
end

-- Writes terrain for island-local rectangle [minX, maxX] x [minZ, maxZ].
-- previous/alpha: optional blend from an older island shape (0 = old, 1 = new).
function IslandTerrain.Write(origin: CFrame, sampler: any, minX: number, maxX: number, minZ: number, maxZ: number, previous: any?, alpha: number?)
	local terrain = workspace.Terrain :: Terrain
	local base = origin.Position
	local x0 = alignDown(base.X + minX)
	local x1 = alignUp(base.X + maxX)
	local z0 = alignDown(base.Z + minZ)
	local z1 = alignUp(base.Z + maxZ)
	local y0 = alignDown(base.Y + Y_MIN)
	local y1 = alignUp(base.Y + Y_MAX)
	local nx = (x1 - x0) // RES
	local ny = (y1 - y0) // RES
	local nz = (z1 - z0) // RES
	local theme = sampler.Theme
	local seabed = materialOf(theme.Seabed)
	local water = Enum.Material.Water
	local air = Enum.Material.Air
	local blend = alpha or 1

	local materials = table.create(nx)
	local occupancies = table.create(nx)
	for i = 1, nx do
		local materialPlane = table.create(ny)
		local occupancyPlane = table.create(ny)
		for j = 1, ny do
			materialPlane[j] = table.create(nz, air)
			occupancyPlane[j] = table.create(nz, 0)
		end
		materials[i] = materialPlane
		occupancies[i] = occupancyPlane
	end

	for i = 1, nx do
		local localX = x0 + (i - 0.5) * RES - base.X
		for k = 1, nz do
			local localZ = z0 + (k - 0.5) * RES - base.Z
			local sample = sampler:Sample(localX, localZ)
			local height = sample.Height
			if previous and blend < 1 then
				local old = previous:Sample(localX, localZ).Height
				height = old + (height - old) * blend
			end
			local surface = materialOf(sample.Material)
			local subsurface = materialOf(SUBSURFACE[sample.Material] or "Ground")
			for j = 1, ny do
				local bottom = y0 + (j - 1) * RES - base.Y
				local fill = math.clamp((height - bottom) / RES, 0, 1)
				if bottom < 0 then
					-- Underwater layer: solid seabed or water (no air pockets in the sea).
					if fill >= 0.5 then
						materials[i][j][k] = if height - bottom <= RES * 1.5 then (if height > -1 then surface else seabed) else subsurface
						occupancies[i][j][k] = 1
					else
						materials[i][j][k] = water
						occupancies[i][j][k] = 1
					end
				elseif fill > 0 then
					materials[i][j][k] = if height - bottom <= RES then surface else subsurface
					occupancies[i][j][k] = fill
				end
			end
		end
	end

	local region = Region3.new(Vector3.new(x0, y0, z0), Vector3.new(x1, y1, z1))
	terrain:WriteVoxels(region, RES, materials, occupancies)
end

-- Writes the whole island in one go.
function IslandTerrain.WriteAll(origin: CFrame, sampler: any)
	local minX, maxX, minZ, maxZ = IslandTerrain.FullBounds()
	IslandTerrain.Write(origin, sampler, minX, maxX, minZ, maxZ)
end

-- Restores open ocean over the whole island area (player left).
function IslandTerrain.Clear(origin: CFrame)
	local terrain = workspace.Terrain :: Terrain
	local minX, maxX, minZ, maxZ = IslandTerrain.FullBounds()
	local base = origin.Position
	local center = Vector3.new(base.X + (minX + maxX) / 2, 0, base.Z + (minZ + maxZ) / 2)
	local size = Vector3.new(maxX - minX + 8, 0, maxZ - minZ + 8)
	local sea = base.Y
	local world = GameConfig.World
	local above = Y_MAX + 8
	terrain:FillBlock(CFrame.new(center.X, sea + above / 2, center.Z), Vector3.new(size.X, above, size.Z), Enum.Material.Air)
	terrain:FillBlock(CFrame.new(center.X, sea - world.OceanDepth / 2, center.Z), Vector3.new(size.X, world.OceanDepth, size.Z), Enum.Material.Water)
	terrain:FillBlock(CFrame.new(center.X, sea - world.OceanDepth - world.SeabedThickness / 2, center.Z), Vector3.new(size.X, world.SeabedThickness, size.Z), Enum.Material.Sand)
end

return IslandTerrain
