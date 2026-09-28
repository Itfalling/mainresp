--[[
	SCRIPT NAME:  CropService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/CropService
	DEPENDENCIES: Shared.Util.CropGrowth, Shared.Config.CropConfig, Server.Island.CropModels

	Crop growth + visuals. Growth is computed from saved timestamps
	(Shared/Util/CropGrowth), so it continues offline and nothing ticks per
	frame: one light loop every 2s checks registered planted tiles and only
	rebuilds a crop model when its STAGE changes.

	FarmService owns tiles and player actions; it registers tiles here and
	listens to StageChanged to refresh prompt text.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local CropConfig = require(Shared.Config.CropConfig)
local CropGrowth = require(Shared.Util.CropGrowth)
local Signal = require(Shared.Util.Signal)
local CropModels = require(script.Parent.Parent.Island.CropModels)

local TICK = 2

local SOIL = {
	Untilled = { Color = Color3.fromRGB(150, 118, 78), Material = Enum.Material.Ground },
	Tilled = { Color = Color3.fromRGB(98, 64, 40), Material = Enum.Material.Ground },
	Watered = { Color = Color3.fromRGB(66, 44, 28), Material = Enum.Material.Ground },
}

export type Tile = {
	Id: string,
	Part: BasePart,
	Entry: any?, -- saved Island.Crops[tileId] or nil (untilled)
	Stage: number,
	CropModel: Model?,
	IslandId: string,
}

local CropService = {}

CropService.StageChanged = Signal.new() -- (tile, stage)

local tiles: { [Tile]: boolean } = {}

local function setAttributes(tile: Tile)
	local entry = tile.Entry
	local part = tile.Part
	part:SetAttribute("TileState", if entry then entry.State else "Untilled")
	part:SetAttribute("CropId", if entry and entry.State == "Planted" then entry.CropId else nil)
	part:SetAttribute("PlantedAt", if entry and entry.State == "Planted" then entry.PlantedAt else nil)
	part:SetAttribute("WateredAt", if entry and entry.State == "Planted" then entry.WateredAt else nil)
	part:SetAttribute("Stage", tile.Stage)
end

-- Rebuilds soil colour + crop model for the tile's current entry.
function CropService.Refresh(tile: Tile)
	local entry = tile.Entry
	local soil = SOIL.Untilled
	if entry then
		soil = if entry.State == "Planted" and CropGrowth.IsWatered(entry) then SOIL.Watered else SOIL.Tilled
	end
	tile.Part.Color = soil.Color
	tile.Part.Material = soil.Material

	if tile.CropModel then
		tile.CropModel:Destroy()
		tile.CropModel = nil
	end
	if entry and entry.State == "Planted" then
		tile.Stage = CropGrowth.GetStage(entry, os.time())
		local top = tile.Part.CFrame * CFrame.new(0, tile.Part.Size.Y / 2, 0)
		local model = CropModels.Build(entry.CropId, tile.Stage, top)
		model.Parent = tile.Part
		tile.CropModel = model
	else
		tile.Stage = 0
	end
	setAttributes(tile)
end

function CropService.Register(tile: Tile)
	tiles[tile] = true
	CropService.Refresh(tile)
end

function CropService.Unregister(tile: Tile)
	tiles[tile] = nil
end

function CropService.UnregisterIsland(islandId: string)
	for tile in table.clone(tiles) do
		if tile.IslandId == islandId then
			tiles[tile] = nil
		end
	end
end

function CropService.IsReady(tile: Tile): boolean
	local entry = tile.Entry
	return entry ~= nil and entry.State == "Planted" and CropGrowth.GetStage(entry, os.time()) >= #CropConfig.Stages
end

function CropService.Start()
	task.spawn(function()
		while true do
			task.wait(TICK)
			local now = os.time()
			for tile in tiles do
				local entry = tile.Entry
				if entry and entry.State == "Planted" and tile.Part.Parent then
					local stage = CropGrowth.GetStage(entry, now)
					if stage ~= tile.Stage then
						CropService.Refresh(tile)
						CropService.StageChanged:Fire(tile, stage)
					end
				end
			end
		end
	end)
end

return CropService
