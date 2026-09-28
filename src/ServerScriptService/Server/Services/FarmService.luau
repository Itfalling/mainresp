--[[
	SCRIPT NAME:  FarmService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/FarmService
	DEPENDENCIES: DataService, IslandService, BuildService, CropService, InventoryService, ProgressionService,
	              InteractionService, ToolService, AnimationService, SoundService, VFXService,
	              Shared.Config.CropConfig, Shared.Util.CropGrowth

	Farming on SOIL TILES — buildings the player places anywhere (six come
	free). Hold something and CLICK a tile:

		Untilled + 🌱 Hoe           -> till       (HoeTill @ Till marker)
		Tilled   + 🌾 seed sack     -> plant it   (PlantSeed @ Plant marker)
		Growing  + 🚿 watering can  -> water      (WaterPlant @ Water marker, 50% faster)
		Ready    + anything         -> harvest    (HarvestCrop @ Pick marker)

	The tile's InteractHint attribute tells the client what the tile needs so
	the hover tooltip can say "Hold your Hoe" before you even click.
	Saved in the OWNER's Island.Crops[tileUniqueId]; helpers can farm too.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local CropConfig = require(Shared.Config.CropConfig)
local CropGrowth = require(Shared.Util.CropGrowth)
local Format = require(Shared.Util.Format)
local Signal = require(Shared.Util.Signal)

local Services = script.Parent
local DataService = require(Services.DataService)
local IslandService = require(Services.IslandService)
local BuildService = require(Services.BuildService)
local CropService = require(Services.CropService)
local InventoryService = require(Services.InventoryService)
local ProgressionService = require(Services.ProgressionService)
local InteractionService = require(Services.InteractionService)
local ToolService = require(Services.ToolService)
local AnimationService = require(Services.AnimationService)
local GameSoundService = require(Services.SoundService)
local VFXService = require(Services.VFXService)
local Notify = require(script.Parent.Parent.Util.Notify)

local FarmService = {}

FarmService.CropPlanted = Signal.new() -- (player, cropId)
FarmService.CropHarvested = Signal.new() -- (player, cropId, amount)

type Tile = {
	Id: string,
	Part: BasePart,
	Entry: any?,
	Stage: number,
	CropModel: Model?,
	IslandId: string,
	Island: any,
}

local tilesById: { [string]: Tile } = {}
local random = Random.new()

local function hintFor(tile: Tile): string
	local entry = tile.Entry
	if not entry then
		return "Till"
	end
	if entry.State == "Tilled" then
		return "Plant"
	end
	if CropService.IsReady(tile) then
		return "Harvest"
	end
	if not CropGrowth.IsWatered(entry) then
		return "Water"
	end
	return "Growing"
end

local function refreshHint(tile: Tile)
	local crop = tile.Entry and tile.Entry.CropId and CropConfig.Crops[tile.Entry.CropId]
	InteractionService.SetText(tile.Part, hintFor(tile), if crop then crop.DisplayName else (if tile.Entry then "Tilled Soil" else "Soil Tile"))
end

local function setEntry(tile: Tile, entry: any)
	tile.Entry = entry
	local owner = tile.Island.Owner
	if owner and owner.Parent then
		DataService.Set(owner, { "Island", "Crops", tile.Id }, entry)
	end
	CropService.Refresh(tile)
	refreshHint(tile)
end

local function soilPart(model: Model): BasePart?
	local soil = model:FindFirstChild("Soil")
	return if soil and soil:IsA("BasePart") then soil else nil
end

local function addTile(site: any)
	local part = soilPart(site.Model)
	if not part or tilesById[site.UniqueId] then
		return
	end
	local island = site.Island
	local tile: Tile = {
		Id = site.UniqueId,
		Part = part,
		Entry = DataService.Get(island.Owner, { "Island", "Crops", site.UniqueId }),
		Stage = 0,
		CropModel = nil,
		IslandId = island.Id,
		Island = island,
	}
	tilesById[site.UniqueId] = tile
	part:SetAttribute("TileId", site.UniqueId)
	InteractionService.Attach(part, "FarmTile", { OwnerUserId = island.OwnerUserId, Label = "Soil Tile", MaxDistance = 7 })
	CropService.Register(tile)
	refreshHint(tile)
end

local function removeTile(site: any)
	local tile = tilesById[site.UniqueId]
	if not tile then
		return
	end
	tilesById[site.UniqueId] = nil
	CropService.Unregister(tile)
	local owner = tile.Island.Owner
	if owner and owner.Parent then
		DataService.Set(owner, { "Island", "Crops", tile.Id }, nil)
	end
end

local function till(player: Player, tile: Tile, hoe: any)
	AnimationService.PerformAction(player, hoe.Animations.Use or "HoeTill", "Till", function()
		if tile.Entry == nil and tilesById[tile.Id] == tile then
			setEntry(tile, { TileId = tile.Id, State = "Tilled" })
			VFXService.PlayAt("DirtPuff", tile.Part.Position + Vector3.new(0, 0.5, 0))
			VFXService.PlayAt("Puff", tile.Part.Position, { Scale = 0.45, Count = 5, Color = Color3.fromRGB(170, 130, 90) })
			VFXService.Jiggle(tile.Part:FindFirstAncestorOfClass("Model"), "Squash")
		end
	end, { Speed = hoe.Speed })
end

local function plant(player: Player, tile: Tile, seedId: string)
	local cropId = CropConfig.SeedToCrop[seedId]
	if not cropId then
		return
	end
	AnimationService.PerformAction(player, "PlantSeed", "Plant", function()
		if tilesById[tile.Id] ~= tile or not tile.Entry or tile.Entry.State ~= "Tilled" then
			return
		end
		if not InventoryService.RemoveItem(player, seedId, 1, "Plant") then
			Notify.Error(player, "You're out of those seeds.")
			return
		end
		setEntry(tile, { TileId = tile.Id, State = "Planted", CropId = cropId, PlantedAt = os.time(), WateredAt = 0 })
		VFXService.PlayAt("DirtPuff", tile.Part.Position + Vector3.new(0, 0.5, 0))
		VFXService.PlayAt("Sparkle", tile.Part.Position + Vector3.new(0, 1, 0), { Count = 6 })
		task.defer(function()
			VFXService.Jiggle(tile.CropModel, "Pop")
		end)
		ProgressionService.Award(player, "PlantCrop")
		FarmService.CropPlanted:Fire(player, cropId)
	end)
end

local function water(player: Player, tile: Tile, can: any)
	local crop = CropConfig.Crops[tile.Entry.CropId]
	AnimationService.PerformAction(player, "WaterPlant", "Water", function()
		local entry = tile.Entry
		if tilesById[tile.Id] == tile and entry and entry.State == "Planted" and not CropGrowth.IsWatered(entry) then
			local watered = table.clone(entry)
			watered.WateredAt = os.time()
			setEntry(tile, watered)
			VFXService.PlayAt("WaterSplash", tile.Part.Position + Vector3.new(0, 1, 0))
			VFXService.Jiggle(tile.CropModel, "Squash")
			Notify.Toast(player, ("%s watered! It grows %d%% faster now."):format(crop.DisplayName, math.floor((CropConfig.WaterSpeedMultiplier - 1) * 100)), "💧")
		end
	end, { Speed = can.Speed })
end

local function harvest(player: Player, tile: Tile)
	local entry = tile.Entry
	local crop = CropConfig.Crops[entry.CropId]
	AnimationService.PerformAction(player, "HarvestCrop", "Pick", function()
		if tilesById[tile.Id] ~= tile or not CropService.IsReady(tile) then
			return
		end
		local amount = random:NextInteger(crop.Yield.Min, crop.Yield.Max)
		local added = InventoryService.AddItem(player, entry.CropId, amount, "Harvest")
		if added <= 0 then
			return -- backpack full: keep the crop in the ground
		end
		setEntry(tile, { TileId = tile.Id, State = "Tilled" })
		GameSoundService.PlayAt("Harvest", tile.Part.Position)
		VFXService.PlayAt("LeafBurst", tile.Part.Position + Vector3.new(0, 1, 0), { Count = 16 })
		VFXService.PlayAt("HitPop", tile.Part.Position + Vector3.new(0, 1.5, 0), { Color = Color3.fromRGB(255, 240, 150) })
		VFXService.PlayAt("Stars", tile.Part.Position + Vector3.new(0, 1.5, 0), { Count = 5 })
		VFXService.Jiggle(tile.Part:FindFirstAncestorOfClass("Model"), "Squash")
		DataService.Increment(player, { "Stats", "CropsHarvested" }, added)
		ProgressionService.Award(player, "HarvestCrop")
		FarmService.CropHarvested:Fire(player, entry.CropId, added)
	end)
end

local function onTileClicked(player: Player, tile: Tile)
	local held = ToolService.GetHeld(player)
	local heldTool = if held and held.Kind == "Tool" then held.Def else nil
	local entry = tile.Entry

	if not entry then
		if heldTool and heldTool.Type == "Hoe" then
			till(player, tile, heldTool)
		else
			Notify.Error(player, "Hold your 🌱 Hoe and click to till this soil.")
		end
		return
	end

	if entry.State == "Tilled" then
		if held and held.Kind == "Item" and CropConfig.SeedToCrop[held.Id] then
			plant(player, tile, held.Id)
		else
			Notify.Error(player, "Hold a seed sack (on your hotbar) and click to plant. Buy seeds at the market!")
		end
		return
	end

	if CropService.IsReady(tile) then
		harvest(player, tile)
		return
	end
	local crop = CropConfig.Crops[entry.CropId]
	if not CropGrowth.IsWatered(entry) and heldTool and heldTool.Type == "WateringCan" then
		water(player, tile, heldTool)
		return
	end
	local remaining = CropGrowth.GetRemaining(entry, os.time())
	local stageName = CropConfig.Stages[CropGrowth.GetStage(entry, os.time())]
	Notify.Toast(
		player,
		("%s · %s · ready in %s%s"):format(crop.DisplayName, stageName, Format.Duration(remaining), if CropGrowth.IsWatered(entry) then " 💧" else " (hold a watering can to speed it up)"),
		crop.Icon
	)
end

-- Admin/testing: finish every crop on the player's island.
function FarmService.GrowAll(player: Player)
	local island = IslandService.GetIsland(player)
	if not island then
		return
	end
	for _, tile in tilesById do
		local entry = tile.Entry
		if tile.IslandId == island.Id and entry and entry.State == "Planted" then
			local crop = CropConfig.Crops[entry.CropId]
			local grown = table.clone(entry)
			grown.PlantedAt = os.time() - crop.GrowTime - 1
			grown.WateredAt = 0
			setEntry(tile, grown)
		end
	end
end

function FarmService.Init()
	InteractionService.RegisterKind("FarmTile", {
		Permission = "Farm",
		MaxDistance = 7,
		Cooldown = 0.25,
		Handler = function(player: Player, part: Instance)
			local tile = tilesById[tostring(part:GetAttribute("TileId"))]
			if tile and tile.Part == part then
				onTileClicked(player, tile)
			end
		end,
	})
end

function FarmService.Start()
	CropService.StageChanged:Connect(function(tile: any)
		refreshHint(tile)
	end)
	BuildService.SiteReady:Connect(function(site: any)
		if site.BuildingId == "SoilTile" then
			addTile(site)
		end
	end)
	BuildService.SiteRemoved:Connect(function(site: any)
		if site.BuildingId == "SoilTile" then
			removeTile(site)
		end
	end)
	BuildService.BuildingMoved:Connect(function(_player: Player, site: any)
		local tile = tilesById[site.UniqueId]
		if tile then
			CropService.Refresh(tile)
		end
	end)
	IslandService.IslandReleased:Connect(function(_player: Player, islandId: string)
		for id, tile in tilesById do
			if tile.IslandId == islandId then
				tilesById[id] = nil
			end
		end
		CropService.UnregisterIsland(islandId)
	end)
end

return FarmService
