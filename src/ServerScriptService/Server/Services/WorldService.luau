--[[
	SCRIPT NAME:  WorldService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/WorldService
	DEPENDENCIES: Shared.Config.{GameConfig, IslandConfig}, Shared.Util.IslandLayout

	Shared world setup (not owned by any single player):
	  * the Workspace folder structure,
	  * lighting: atmosphere, 3D clouds, sun rays, bloom, colour grading and
	    a gentle day / night cycle (short, moonlit nights),
	  * terrain material colours, clear turquoise water and the ocean
	    around every island slot.
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

local function ensure(className: string, parent: Instance): any
	return parent:FindFirstChildOfClass(className) or Instance.new(className)
end

local function applyLighting()
	Lighting.ClockTime = WorldConfig.ClockTime
	Lighting.Brightness = WorldConfig.Brightness
	Lighting.Ambient = WorldConfig.Ambient
	Lighting.OutdoorAmbient = WorldConfig.OutdoorAmbient
	Lighting.EnvironmentDiffuseScale = WorldConfig.EnvironmentDiffuseScale
	Lighting.EnvironmentSpecularScale = WorldConfig.EnvironmentSpecularScale
	Lighting.ShadowSoftness = WorldConfig.ShadowSoftness
	Lighting.GlobalShadows = true

	local atmosphere = ensure("Atmosphere", Lighting)
	atmosphere.Density = WorldConfig.Atmosphere.Density
	atmosphere.Offset = WorldConfig.Atmosphere.Offset
	atmosphere.Color = WorldConfig.Atmosphere.Color
	atmosphere.Decay = WorldConfig.Atmosphere.Decay
	atmosphere.Glare = WorldConfig.Atmosphere.Glare
	atmosphere.Haze = WorldConfig.Atmosphere.Haze
	atmosphere.Parent = Lighting

	local bloom = ensure("BloomEffect", Lighting)
	bloom.Intensity = WorldConfig.Bloom.Intensity
	bloom.Size = WorldConfig.Bloom.Size
	bloom.Threshold = WorldConfig.Bloom.Threshold
	bloom.Parent = Lighting

	local color = ensure("ColorCorrectionEffect", Lighting)
	color.Saturation = WorldConfig.ColorCorrection.Saturation
	color.Contrast = WorldConfig.ColorCorrection.Contrast
	color.Brightness = WorldConfig.ColorCorrection.Brightness
	color.TintColor = WorldConfig.ColorCorrection.TintColor
	color.Parent = Lighting

	local sunRays = ensure("SunRaysEffect", Lighting)
	sunRays.Intensity = WorldConfig.SunRays.Intensity
	sunRays.Spread = WorldConfig.SunRays.Spread
	sunRays.Parent = Lighting

	-- Dynamic 3D clouds live under Terrain.
	local terrain = workspace.Terrain :: Terrain
	local clouds = ensure("Clouds", terrain)
	clouds.Cover = WorldConfig.Clouds.Cover
	clouds.Density = WorldConfig.Clouds.Density
	clouds.Color = WorldConfig.Clouds.Color
	clouds.Parent = terrain
end

-- Day / night: days last DayMinutes, nights pass NightSpeed x faster and
-- keep a bright moonlit ambient so the island is always readable.
local function runDayCycle()
	if not WorldConfig.DayCycle then
		return
	end
	local hoursPerSecond = 24 / (WorldConfig.DayMinutes * 60)
	local dayAmbient = WorldConfig.OutdoorAmbient
	local nightAmbient = WorldConfig.NightOutdoorAmbient
	task.spawn(function()
		local last = os.clock()
		while true do
			task.wait(0.5)
			local now = os.clock()
			local clock = Lighting.ClockTime
			local night = clock < 6 or clock > 18.5
			local speed = if night then WorldConfig.NightSpeed else 1
			Lighting.ClockTime = (clock + (now - last) * hoursPerSecond * speed) % 24
			last = now
			-- Blend the ambient around dusk and dawn.
			local daylight = math.clamp(math.min(clock - 5.5, 19 - clock) / 1.5, 0, 1)
			Lighting.OutdoorAmbient = nightAmbient:Lerp(dayAmbient, daylight)
		end
	end)
end

local function applyTerrainLook()
	local terrain = workspace.Terrain :: Terrain
	terrain.WaterColor = WorldConfig.WaterColor
	terrain.WaterTransparency = WorldConfig.WaterTransparency
	terrain.WaterReflectance = WorldConfig.WaterReflectance
	terrain.WaterWaveSize = WorldConfig.WaterWaveSize
	terrain.WaterWaveSpeed = WorldConfig.WaterWaveSpeed
	-- Terrain.Decoration (animated grass) can't be set from scripts; the
	-- place file turns it on (default.project.json → Workspace.Terrain).
	for materialName, materialColor in WorldConfig.MaterialColors do
		local material = (Enum.Material :: any)[materialName]
		if material then
			terrain:SetMaterialColor(material, materialColor)
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
	runDayCycle()
	fillOcean()
	-- Slot 1 origin sanity check for the log (helps when debugging layouts).
	if GameConfig.Debug then
		print("[WorldService] Ocean ready. Slot 1 origin:", IslandLayout.GetSlotOrigin(1).Position)
	end
end

return WorldService
