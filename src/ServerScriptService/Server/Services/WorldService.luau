--[[
	SCRIPT NAME:  WorldService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/WorldService
	DEPENDENCIES: Shared.Config.{GameConfig, IslandConfig}, Shared.Util.IslandLayout

	Shared world setup (not owned by any single player):
	  * the Workspace folder structure,
	  * base lighting + atmosphere (WeatherService takes over in Phase 13),
	  * terrain materials + the ocean around every island slot.
]]

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.Config.GameConfig)
local IslandConfig = require(Shared.Config.IslandConfig)
local IslandLayout = require(Shared.Util.IslandLayout)

local WorldConfig = GameConfig.World

local WORKSPACE_FOLDERS = { "Islands", "ResourceZones", "NPCs", "FishingZones", "World" }

local WorldService = {}

WorldService.Folders = {} :: { [string]: Folder }

function WorldService.GetFolder(name: string): Folder
	local folder = WorldService.Folders[name]
	assert(folder, "Unknown workspace folder " .. name)
	return folder
end

local function ensureFolders()
	for _, name in WORKSPACE_FOLDERS do
		local folder = workspace:FindFirstChild(name)
		if not folder then
			folder = Instance.new("Folder")
			folder.Name = name
			folder.Parent = workspace
		end
		WorldService.Folders[name] = folder :: Folder
	end
end

local function applyLighting()
	Lighting.ClockTime = WorldConfig.ClockTime
	Lighting.Brightness = WorldConfig.Brightness
	Lighting.Ambient = WorldConfig.Ambient
	Lighting.OutdoorAmbient = WorldConfig.OutdoorAmbient
	Lighting.EnvironmentDiffuseScale = WorldConfig.EnvironmentDiffuseScale
	Lighting.EnvironmentSpecularScale = WorldConfig.EnvironmentSpecularScale
	Lighting.GlobalShadows = true

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
	atmosphere.Density = WorldConfig.Atmosphere.Density
	atmosphere.Offset = WorldConfig.Atmosphere.Offset
	atmosphere.Color = WorldConfig.Atmosphere.Color
	atmosphere.Decay = WorldConfig.Atmosphere.Decay
	atmosphere.Glare = WorldConfig.Atmosphere.Glare
	atmosphere.Haze = WorldConfig.Atmosphere.Haze
	atmosphere.Parent = Lighting

	if not Lighting:FindFirstChildOfClass("BloomEffect") then
		local bloom = Instance.new("BloomEffect")
		bloom.Intensity = 0.4
		bloom.Size = 20
		bloom.Threshold = 1.6
		bloom.Parent = Lighting
	end
	if not Lighting:FindFirstChildOfClass("ColorCorrectionEffect") then
		local color = Instance.new("ColorCorrectionEffect")
		color.Saturation = 0.12
		color.Contrast = 0.05
		color.Parent = Lighting
	end
end

local function applyTerrainLook()
	local terrain = workspace.Terrain :: Terrain
	terrain.WaterColor = WorldConfig.WaterColor
	terrain.WaterTransparency = WorldConfig.WaterTransparency
	terrain.WaterReflectance = WorldConfig.WaterReflectance
	terrain.WaterWaveSize = WorldConfig.WaterWaveSize
	terrain.WaterWaveSpeed = WorldConfig.WaterWaveSpeed
	-- Note: Terrain.Decoration (animated grass) can't be set from scripts;
	-- toggle it on Workspace.Terrain in Studio's Properties window instead.
	for materialName, color in WorldConfig.MaterialColors do
		local material = (Enum.Material :: any)[materialName]
		if material then
			terrain:SetMaterialColor(material, color)
		end
	end
end

-- Fills the ocean (water + sand seabed) under every island slot, in tiles.
local function fillOcean()
	local terrain = workspace.Terrain :: Terrain
	local slotCount = GameConfig.MaxIslandsPerServer
	local rows = math.ceil(slotCount / IslandConfig.SlotsPerRow)
	local columns = math.min(slotCount, IslandConfig.SlotsPerRow)
	local margin = WorldConfig.OceanMargin
	local minX = -margin
	local minZ = -margin
	local maxX = (columns - 1) * IslandConfig.SlotSpacing + margin
	local maxZ = (rows - 1) * IslandConfig.SlotSpacing + margin
	local tile = WorldConfig.OceanTileSize
	local sea = IslandConfig.SeaLevel
	local depth = WorldConfig.OceanDepth
	local bed = WorldConfig.SeabedThickness

	for x = minX, maxX - 1, tile do
		for z = minZ, maxZ - 1, tile do
			local sizeX = math.min(tile, maxX - x)
			local sizeZ = math.min(tile, maxZ - z)
			local centerX = x + sizeX / 2
			local centerZ = z + sizeZ / 2
			terrain:FillBlock(CFrame.new(centerX, sea - depth / 2, centerZ), Vector3.new(sizeX, depth, sizeZ), Enum.Material.Water)
			terrain:FillBlock(CFrame.new(centerX, sea - depth - bed / 2, centerZ), Vector3.new(sizeX, bed, sizeZ), Enum.Material.Sand)
		end
		task.wait() -- spread the work over a few frames
	end
end

-- Restores open ocean in a cylinder (used when an island is cleaned up).
function WorldService.RestoreOcean(center: Vector3, radius: number)
	local terrain = workspace.Terrain :: Terrain
	local sea = IslandConfig.SeaLevel
	local depth = WorldConfig.OceanDepth
	local bed = WorldConfig.SeabedThickness
	local airHeight = 120
	terrain:FillCylinder(CFrame.new(center.X, sea + airHeight / 2, center.Z), airHeight, radius, Enum.Material.Air)
	terrain:FillCylinder(CFrame.new(center.X, sea - depth / 2, center.Z), depth, radius, Enum.Material.Water)
	terrain:FillCylinder(CFrame.new(center.X, sea - depth - bed / 2, center.Z), bed, radius, Enum.Material.Sand)
end

function WorldService.Init()
	ensureFolders()
end

function WorldService.Start()
	applyLighting()
	applyTerrainLook()
	fillOcean()
	-- Slot 1 origin sanity check for the log (helps when debugging layouts).
	if GameConfig.Debug then
		print("[WorldService] Ocean ready. Slot 1 origin:", IslandLayout.GetSlotOrigin(1).Position)
	end
end

return WorldService
