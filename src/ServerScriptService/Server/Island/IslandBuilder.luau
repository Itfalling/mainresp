--[[
	SCRIPT NAME:  IslandBuilder
	SCRIPT TYPE:  ModuleScript (server)
	WHERE:        ServerScriptService/Server/Island/IslandBuilder
	DEPENDENCIES: Shared.Config.IslandConfig, Shared.Util.IslandGen,
	              Server.Island.{IslandProps, IslandTerrain}

	Builds the physical island for one slot from its saved data:
	  * the island Model and its standard folder layout,
	  * smooth terrain for every owned chunk (IslandTerrain),
	  * landmarks at the plaza (spawn pad, island sign, starter chest),
	  * cosmetic decoration scatter per chunk (flowers, tufts, shells...).

	Positions are island-local and converted with the slot origin, so the same
	island builds identically in any slot on any server.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Shared = ReplicatedStorage.Shared
local IslandConfig = require(Shared.Config.IslandConfig)
local IslandGen = require(Shared.Util.IslandGen)
local IslandProps = require(script.Parent.IslandProps)
local IslandTerrain = require(script.Parent.IslandTerrain)

local IslandBuilder = {}

-- Folders every island model contains.
IslandBuilder.FolderNames = {
	"Terrain",
	"Props", -- non-blocking scenery
	"Landmarks", -- spawn pad: never built over
	"Interactables", -- sign, chest
	"Buildings",
	"Decorations", -- cosmetic scatter (never blocks anything)
	"Resources",
	"Crops",
	"Animals",
	"Production",
}

local terrainParams = RaycastParams.new()
terrainParams.FilterType = Enum.RaycastFilterType.Include
terrainParams.IgnoreWater = true

local function toWorld(origin: CFrame, localXZ: Vector2, y: number?): Vector3
	return (origin * CFrame.new(localXZ.X, y or 0, localXZ.Y)).Position
end

-- World CFrame on the terrain surface at an island-local XZ point.
function IslandBuilder.GroundCFrame(origin: CFrame, localXZ: Vector2, yawDegrees: number?): CFrame
	terrainParams.FilterDescendantsInstances = { workspace.Terrain }
	local top = toWorld(origin, localXZ, 80)
	local result = workspace:Raycast(top, Vector3.new(0, -160, 0), terrainParams)
	local y = if result then result.Position.Y else origin.Position.Y + IslandConfig.LandHeight
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
	Sign: Model,
	Chest: Model,
	SpawnCFrame: CFrame,
}

function IslandBuilder.CreateModel(name: string, parent: Instance, origin: CFrame): (Model, { [string]: Folder })
	local model = Instance.new("Model")
	model.Name = name
	model.ModelStreamingMode = Enum.ModelStreamingMode.Default
	-- No PrimaryPart: pin the pivot to the island origin so clients can use
	-- island:GetPivot() as the origin of island-local coordinates.
	model.WorldPivot = origin
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

-- Decoration scatter for one chunk. Existing scatter for that chunk is replaced.
function IslandBuilder.DecorateChunk(origin: CFrame, folders: { [string]: Folder }, sampler: any, cx: number, cz: number)
	local key = IslandGen.Key(cx, cz)
	IslandBuilder.ClearChunkDeco(folders, key)
	for index, deco in IslandGen.ChunkDeco(sampler, cx, cz) do
		local model = IslandProps.Deco(deco.Kind, sampler.Data.Seed + cx * 131 + cz * 17 + index, deco.Scale)
		if model then
			model:SetAttribute("Chunk", key)
			place(model, folders.Decorations, IslandBuilder.GroundCFrame(origin, deco.Position, deco.Yaw))
		end
	end
end

function IslandBuilder.ClearChunkDeco(folders: { [string]: Folder }, key: string)
	for _, child in folders.Decorations:GetChildren() do
		if child:GetAttribute("Chunk") == key then
			child:Destroy()
		end
	end
end

-- Terrain + landmarks + decoration. Yields between decoration batches.
function IslandBuilder.Build(origin: CFrame, folders: { [string]: Folder }, sampler: any): BuiltIsland
	IslandTerrain.WriteAll(origin, sampler)

	local layout = IslandConfig.StarterLayout
	local spawnYaw = facing(layout.Spawn, layout.Spawn + layout.SpawnFacing)
	local spawnGround = IslandBuilder.GroundCFrame(origin, layout.Spawn, spawnYaw)
	place(customProp("SpawnPad") or IslandProps.SpawnPad(), folders.Landmarks, spawnGround)
	local spawnCFrame = spawnGround + Vector3.new(0, 4, 0)

	local sign = customProp("IslandSign") or IslandProps.Sign("My Island", "Island Level 1")
	place(sign, folders.Interactables, IslandBuilder.GroundCFrame(origin, layout.IslandSign, facing(layout.IslandSign, layout.Spawn)))

	local chest = customProp("StarterChest") or IslandProps.StarterChest()
	place(chest, folders.Interactables, IslandBuilder.GroundCFrame(origin, layout.StarterChest, facing(layout.StarterChest, layout.Spawn)))

	local count = 0
	for key, owned in sampler.Data.Chunks do
		local cx, cz = IslandGen.ParseKey(key)
		if owned and cx and cz then
			IslandBuilder.DecorateChunk(origin, folders, sampler, cx, cz)
			count += 1
			if count % 40 == 0 then
				task.wait()
			end
		end
	end

	return { Sign = sign, Chest = chest, SpawnCFrame = spawnCFrame }
end

return IslandBuilder
