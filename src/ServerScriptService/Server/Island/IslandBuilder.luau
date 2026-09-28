--[[
	SCRIPT NAME:  IslandBuilder
	SCRIPT TYPE:  ModuleScript (server)
	WHERE:        ServerScriptService/Server/Island/IslandBuilder
	DEPENDENCIES: Shared.Config.IslandConfig, Shared.Util.IslandLayout, Server.Island.IslandProps

	Builds and tears down the physical island for one slot:
	  * smooth-terrain land lobes (starter + each UNLOCKED area),
	  * underwater sandbars previewing LOCKED areas,
	  * the island Model and its standard folder layout,
	  * starter props (spawn pad, sign, chest, dock, plots, palms, flowers).

	All positions come from IslandConfig in island-local space and are
	converted with the slot origin, so the same island builds identically in
	any slot on any server.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Shared = ReplicatedStorage.Shared
local IslandConfig = require(Shared.Config.IslandConfig)
local IslandLayout = require(Shared.Util.IslandLayout)
local IslandProps = require(script.Parent.IslandProps)

local IslandBuilder = {}

-- Folders every island model contains (later phases fill them).
IslandBuilder.FolderNames = {
	"Terrain",
	"Props",
	"Interactables",
	"AreaMarkers",
	"Buildings",
	"Decorations",
	"Resources",
	"Crops",
	"Animals",
	"Production",
	"FishingSpots",
}

local BIOME_SURFACE: { [string]: Enum.Material } = {
	Meadow = Enum.Material.Grass,
	Forest = Enum.Material.LeafyGrass,
	River = Enum.Material.Grass,
	Beach = Enum.Material.Sand,
	Mountain = Enum.Material.Rock,
	Cave = Enum.Material.Ground,
}

local terrainParams = RaycastParams.new()
terrainParams.FilterType = Enum.RaycastFilterType.Include
terrainParams.IgnoreWater = true

local function toWorld(origin: CFrame, localXZ: Vector2, y: number?): Vector3
	return (origin * CFrame.new(localXZ.X, y or 0, localXZ.Y)).Position
end

local function fillColumn(terrain: Terrain, center: Vector3, radius: number, bottom: number, top: number, material: Enum.Material)
	local height = top - bottom
	if height <= 0 or radius <= 0 then
		return
	end
	terrain:FillCylinder(CFrame.new(center.X, (top + bottom) / 2, center.Z), height, radius, material)
end

-- Raises one land lobe. `scale` (0..1] lets unlock animations grow the land.
function IslandBuilder.FillAreaLand(origin: CFrame, areaId: string, scale: number?)
	local area = IslandConfig.Areas[areaId]
	local terrain = workspace.Terrain :: Terrain
	local center = toWorld(origin, IslandLayout.GetAreaCenter(areaId))
	local sea = origin.Position.Y
	local bottom = sea - IslandConfig.LandDepth
	local s = scale or 1
	local radius = area.Radius * s
	local surface = BIOME_SURFACE[area.Biome] or Enum.Material.Grass

	fillColumn(terrain, center, radius + IslandConfig.ShallowsWidth * s, bottom, sea + IslandConfig.ShallowsHeight, Enum.Material.Sand)
	fillColumn(terrain, center, radius + IslandConfig.BeachWidth * s, bottom, sea + IslandConfig.BeachHeight, Enum.Material.Sand)
	fillColumn(terrain, center, radius, bottom, sea + IslandConfig.SurfaceHeight, surface)
end

function IslandBuilder.FillAreaSandbar(origin: CFrame, areaId: string)
	local area = IslandConfig.Areas[areaId]
	local center = toWorld(origin, IslandLayout.GetAreaCenter(areaId))
	local sea = origin.Position.Y
	fillColumn(workspace.Terrain :: Terrain, center, area.Radius, sea - IslandConfig.LandDepth, sea - IslandConfig.SandbarDepth, Enum.Material.Sand)
end

local function fillHills(origin: CFrame)
	for _, hill in IslandConfig.StarterLayout.Hills do
		-- Sink the ball so only a gentle `Height`-stud dome shows above the surface.
		local center = toWorld(origin, hill.Center, IslandConfig.SurfaceHeight + hill.Height - hill.Radius)
		local terrain = workspace.Terrain :: Terrain
		terrain:FillBall(center, hill.Radius, Enum.Material.Grass)
	end
end

-- Terrain height at an island-local XZ point (falls back to surface height).
function IslandBuilder.GroundCFrame(origin: CFrame, localXZ: Vector2, yawDegrees: number?): CFrame
	terrainParams.FilterDescendantsInstances = { workspace.Terrain }
	local top = toWorld(origin, localXZ, 80)
	local result = workspace:Raycast(top, Vector3.new(0, -160, 0), terrainParams)
	local y = if result then result.Position.Y else origin.Position.Y + IslandConfig.SurfaceHeight
	return CFrame.new(top.X, y, top.Z) * CFrame.Angles(0, math.rad(yawDegrees or 0), 0)
end

-- Yaw (degrees) that makes a prop's -Z face from `from` towards `to` (island-local).
local function facing(from: Vector2, to: Vector2): number
	local direction = to - from
	return math.deg(math.atan2(-direction.X, -direction.Y))
end

local function customProp(name: string): Model?
	local islands = ServerStorage:FindFirstChild("Islands")
	local props = islands and islands:FindFirstChild("Props")
	local template = props and props:FindFirstChild(name)
	if template and template:IsA("Model") then
		return template:Clone()
	end
	return nil
end

local function place(model: Model, parent: Instance, cframe: CFrame): Model
	model:PivotTo(cframe)
	model.Parent = parent
	return model
end

export type BuiltIsland = {
	Model: Model,
	Folders: { [string]: Folder },
	Sign: Model,
	Chest: Model,
	SpawnCFrame: CFrame,
}

function IslandBuilder.CreateModel(name: string, parent: Instance): (Model, { [string]: Folder })
	local model = Instance.new("Model")
	model.Name = name
	model.ModelStreamingMode = Enum.ModelStreamingMode.Default
	local folders = {}
	for _, folderName in IslandBuilder.FolderNames do
		local folder = Instance.new("Folder")
		folder.Name = folderName
		folder.Parent = model
		folders[folderName] = folder
	end
	model.Parent = parent
	return model, folders
end

-- Builds terrain + starter props. `unlocked` = profile Island.UnlockedAreas.
function IslandBuilder.Build(origin: CFrame, model: Model, folders: { [string]: Folder }, unlocked: { [string]: boolean }): BuiltIsland
	-- Terrain: locked sandbars first, then land (starter first so lobes merge onto it).
	for _, areaId in IslandConfig.AreaOrder do
		if not unlocked[areaId] then
			IslandBuilder.FillAreaSandbar(origin, areaId)
		end
	end
	for _, areaId in IslandConfig.AreaOrder do
		if unlocked[areaId] then
			IslandBuilder.FillAreaLand(origin, areaId)
		end
	end
	fillHills(origin)

	local layout = IslandConfig.StarterLayout
	local props = folders.Props
	local interactables = folders.Interactables

	-- Spawn
	local spawnYaw = facing(layout.Spawn, layout.Spawn + layout.SpawnFacing)
	local spawnGround = IslandBuilder.GroundCFrame(origin, layout.Spawn, spawnYaw)
	place(customProp("SpawnPad") or IslandProps.SpawnPad(), props, spawnGround)
	local spawnCFrame = spawnGround + Vector3.new(0, 4, 0)

	-- Island sign faces the spawn point.
	local sign = customProp("IslandSign") or IslandProps.Sign("My Island", "Island Level 1")
	place(sign, interactables, IslandBuilder.GroundCFrame(origin, layout.IslandSign, facing(layout.IslandSign, layout.Spawn)))

	-- Starter chest faces the spawn point.
	local chest = customProp("StarterChest") or IslandProps.StarterChest()
	place(chest, interactables, IslandBuilder.GroundCFrame(origin, layout.StarterChest, facing(layout.StarterChest, layout.Spawn)))

	-- Dock runs out to sea along +Z (local).
	local dockStart = layout.Dock.Start
	local dockCFrame = toWorld(origin, dockStart, 2.2)
	place(customProp("Dock") or IslandProps.Dock(layout.Dock.Length, layout.Dock.Width), props, CFrame.new(dockCFrame) * CFrame.Angles(0, math.pi, 0))

	-- Plots (Phase 3 building + Phase 4 farming use these zones).
	local housePlot = place(customProp("HousePlot") or IslandProps.Plot("HousePlot", layout.HousePlot.Size), props, IslandBuilder.GroundCFrame(origin, layout.HousePlot.Center))
	housePlot:SetAttribute("Zone", "House")
	local farmPlot = place(customProp("FarmPlot") or IslandProps.Plot("FarmPlot", layout.FarmPlot.Size), props, IslandBuilder.GroundCFrame(origin, layout.FarmPlot.Center))
	farmPlot:SetAttribute("Zone", "Farm")

	-- Decoration (non-harvestable; gatherable trees arrive in Phase 2).
	for index, position in layout.Palms do
		place(IslandProps.Palm(14 + (index % 3) * 2, index), folders.Decorations, IslandBuilder.GroundCFrame(origin, position, index * 47))
	end
	for index, position in layout.FlowerPatches do
		place(IslandProps.Flowers(index * 13), folders.Decorations, IslandBuilder.GroundCFrame(origin, position))
	end

	return {
		Model = model,
		Folders = folders,
		Sign = sign,
		Chest = chest,
		SpawnCFrame = spawnCFrame,
	}
end

-- Places the 🔒 marker for a locked area. Returns the marker model.
function IslandBuilder.CreateAreaMarker(origin: CFrame, parent: Instance, areaId: string, requirementText: string): Model
	local area = IslandConfig.Areas[areaId]
	local position = IslandLayout.GetAreaMarkerPosition(areaId)
	-- The rope + stake side faces out towards the locked land; the post faces home.
	local marker = IslandProps.LockMarker(area.DisplayName, requirementText)
	marker:SetAttribute("AreaId", areaId)
	return place(marker, parent, IslandBuilder.GroundCFrame(origin, position, facing(position, Vector2.zero)))
end

-- Clears all island terrain back to open ocean. Used when a player leaves.
function IslandBuilder.ClearTerrain(origin: CFrame, restoreOcean: (center: Vector3, radius: number) -> ())
	for _, areaId in IslandConfig.AreaOrder do
		local area = IslandConfig.Areas[areaId]
		local center = toWorld(origin, IslandLayout.GetAreaCenter(areaId))
		restoreOcean(center, area.Radius + IslandConfig.ShallowsWidth + 4)
	end
end

return IslandBuilder
