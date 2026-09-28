--[[
	SCRIPT NAME:  FarmService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/FarmService
	DEPENDENCIES: DataService, IslandService, CropService, InventoryService, ProgressionService,
	              InteractionService, ToolService, AnimationService, AntiExploitService,
	              SoundService, VFXService, Server.Island.IslandProps,
	              Shared.Config.{CropConfig, IslandConfig}, Shared.Util.{IslandContent, Serializer}

	Farm plots and tiles (spec §20-§23, §142). One prompt per tile whose text
	follows the tile's state:

		Untilled  -> "Till Soil"     (equips your hoe, TillGround @ Till marker)
		Tilled    -> "Plant Seeds"   (one seed type: plants it; several: opens the
		                              seed picker, which sends PlantCropRequest)
		Growing   -> "Water"         (equips watering can, WaterPlant @ Water marker)
		Watered   -> "Check Crop"    (shows time left)
		Ready     -> "Harvest Wheat" (HarvestCrop @ Pick marker -> produce + XP)

	Every change is validated here and saved to Island.Crops[tileId].
	Tiles unlocked: the starter plot uses Island.FarmTiles (shop upgrade);
	area plots (Sunny Fields) come fully unlocked.
]]

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local CropConfig = require(Shared.Config.CropConfig)
local IslandContent = require(Shared.Util.IslandContent)
local CropGrowth = require(Shared.Util.CropGrowth)
local Serializer = require(Shared.Util.Serializer)
local Validate = require(Shared.Util.Validate)
local Format = require(Shared.Util.Format)
local Signal = require(Shared.Util.Signal)
local R15 = require(Shared.Util.R15)

local Services = script.Parent
local DataService = require(Services.DataService)
local IslandService = require(Services.IslandService)
local CropService = require(Services.CropService)
local InventoryService = require(Services.InventoryService)
local ProgressionService = require(Services.ProgressionService)
local InteractionService = require(Services.InteractionService)
local ToolService = require(Services.ToolService)
local AnimationService = require(Services.AnimationService)
local AntiExploitService = require(Services.AntiExploitService)
local GameSoundService = require(Services.SoundService)
local VFXService = require(Services.VFXService)
local IslandProps = require(script.Parent.Parent.Island.IslandProps)
local Notify = require(script.Parent.Parent.Util.Notify)

local TILE_TAG = "FarmTile"
local TILE_RANGE = 14
local PLOT_SIZE = Vector2.new(20, 16)

local FarmService = {}

FarmService.CropPlanted = Signal.new() -- (player, cropId)
FarmService.CropHarvested = Signal.new() -- (player, cropId, amount)

type IslandFarm = { Island: any, Owner: Player, Tiles: { [string]: any }, Plots: { [string]: boolean } }

local farms: { [string]: IslandFarm } = {} -- islandId -> farm
local random = Random.new()

local function tileAction(tile: any): (string, string)
	local entry = tile.Entry
	if not entry then
		return "Till Soil", "Farm Tile"
	end
	if entry.State == "Tilled" then
		return "Plant Seeds", "Tilled Soil"
	end
	local crop = CropConfig.Crops[entry.CropId]
	local name = if crop then crop.DisplayName else "Crop"
	if CropService.IsReady(tile) then
		return "Harvest " .. name, name
	end
	if not CropGrowth.IsWatered(entry) then
		return "Water", name
	end
	return "Check Crop", name
end

local function refreshPrompt(tile: any)
	local actionText, objectText = tileAction(tile)
	InteractionService.SetText(tile.Part, actionText, objectText)
end

local function setEntry(farm: IslandFarm, tile: any, entry: any)
	tile.Entry = entry
	DataService.Set(farm.Owner, { "Island", "Crops", tile.Id }, entry)
	CropService.Refresh(tile)
	refreshPrompt(tile)
end

local function createTile(farm: IslandFarm, tileId: string, localXZ: Vector2)
	if farm.Tiles[tileId] then
		return
	end
	local island = farm.Island
	local ground = IslandService.GetGroundCFrame(island, localXZ)
	local size = CropConfig.Farm.TileSize
	local part = Instance.new("Part")
	part.Name = "Tile_" .. tileId
	part.Anchored = true
	part.CanCollide = true
	part.Size = Vector3.new(size, 0.5, size)
	part.CFrame = ground * CFrame.new(0, 0.15, 0)
	part.TopSurface = Enum.SurfaceType.Smooth
	part:SetAttribute("TileId", tileId)
	part:SetAttribute("OwnerUserId", island.OwnerUserId)
	part.Parent = island.Folders.Crops
	CollectionService:AddTag(part, TILE_TAG)

	local saved = DataService.Get(farm.Owner, { "Island", "Crops", tileId })
	local tile = {
		Id = tileId,
		Part = part,
		Entry = saved,
		Stage = 0,
		CropModel = nil,
		IslandId = island.Id,
		LocalPosition = localXZ,
	}
	farm.Tiles[tileId] = tile
	InteractionService.Attach(part, "FarmTile", { OwnerUserId = island.OwnerUserId, MaxDistance = 8 })
	CropService.Register(tile)
	refreshPrompt(tile)
end

-- Creates plot outlines + all unlocked tiles for the island.
function FarmService.RefreshFarm(player: Player)
	local island = IslandService.GetIsland(player)
	local farm = island and farms[island.Id]
	if not island or not farm then
		return
	end
	local unlocked = IslandService.GetUnlockedAreas(player)
	local starterTiles = DataService.Get(player, { "Island", "FarmTiles" }) or CropConfig.Farm.StarterTiles
	for _, plot in IslandContent.FarmPlots() do
		if unlocked[plot.AreaId] then
			if not farm.Plots[plot.Id] then
				farm.Plots[plot.Id] = true
				local outline = IslandProps.Plot("FarmPlot", PLOT_SIZE)
				outline.Name = "FarmPlot_" .. plot.Id
				outline:PivotTo(IslandService.GetGroundCFrame(island, plot.Center))
				outline.Parent = island.Folders.Landmarks
			end
			local positions = IslandContent.FarmTilePositions(plot.Center)
			local count = if plot.Id == "S" then math.min(starterTiles, #positions) else #positions
			for index = 1, count do
				createTile(farm, plot.Id .. index, positions[index])
			end
		end
	end
end

local function getTile(player: Player, tileId: any): (any?, IslandFarm?)
	if type(tileId) ~= "string" then
		return nil, nil
	end
	local island = IslandService.GetIsland(player)
	local farm = island and farms[island.Id]
	if not farm then
		return nil, nil
	end
	return farm.Tiles[tileId], farm
end

local function nearTile(player: Player, tile: any): boolean
	local root = R15.GetRootPart(player.Character)
	return root ~= nil and (root.Position - tile.Part.Position).Magnitude <= TILE_RANGE
end

local function ownedSeeds(player: Player): { string }
	local seeds = {}
	for _, cropId in CropConfig.Order do
		local seedId = CropConfig.Crops[cropId].Seed
		if InventoryService.GetCount(player, seedId) > 0 then
			table.insert(seeds, seedId)
		end
	end
	return seeds
end

local function plant(player: Player, farm: IslandFarm, tile: any, seedId: string)
	local cropId = CropConfig.SeedToCrop[seedId]
	if not cropId then
		return
	end
	AnimationService.PerformAction(player, "PlantSeed", "Plant", function()
		if not tile.Entry or tile.Entry.State ~= "Tilled" then
			return
		end
		if not InventoryService.RemoveItem(player, seedId, 1, "Plant") then
			Notify.Error(player, "You're out of those seeds.")
			return
		end
		setEntry(farm, tile, {
			TileId = tile.Id,
			State = "Planted",
			CropId = cropId,
			Position = Serializer.Vector3(Vector3.new(tile.LocalPosition.X, 0, tile.LocalPosition.Y)),
			PlantedAt = os.time(),
			WateredAt = 0,
		})
		VFXService.PlayAt("DirtPuff", tile.Part.Position + Vector3.new(0, 0.5, 0))
		ProgressionService.Award(player, "PlantCrop")
		FarmService.CropPlanted:Fire(player, cropId)
	end)
end

local function onTileUsed(player: Player, farm: IslandFarm, tile: any)
	local entry = tile.Entry
	if not entry then
		-- Till
		local hoe = ToolService.EquipBestOfType(player, "Hoe")
		if not hoe then
			Notify.Error(player, "You need a Hoe to till soil.")
			return
		end
		AnimationService.PerformAction(player, hoe.Animations.Use or "HoeTill", "Till", function()
			if tile.Entry == nil then
				setEntry(farm, tile, { TileId = tile.Id, State = "Tilled", Position = Serializer.Vector3(Vector3.new(tile.LocalPosition.X, 0, tile.LocalPosition.Y)) })
				VFXService.PlayAt("DirtPuff", tile.Part.Position + Vector3.new(0, 0.5, 0))
			end
		end, { Speed = hoe.Speed })
		return
	end

	if entry.State == "Tilled" then
		local seeds = ownedSeeds(player)
		if #seeds == 0 then
			Notify.Error(player, "You have no seeds — buy some at the market stall!")
		elseif #seeds == 1 then
			plant(player, farm, tile, seeds[1])
		else
			local options = {}
			for _, seedId in seeds do
				table.insert(options, { Seed = seedId, Count = InventoryService.GetCount(player, seedId) })
			end
			Net.FireClient("OpenUI", player, { Screen = "SeedPicker", TileId = tile.Id, Seeds = options })
		end
		return
	end

	local crop = CropConfig.Crops[entry.CropId]
	if CropService.IsReady(tile) then
		AnimationService.PerformAction(player, "HarvestCrop", "Pick", function()
			if not CropService.IsReady(tile) then
				return
			end
			local amount = random:NextInteger(crop.Yield.Min, crop.Yield.Max)
			local added = InventoryService.AddItem(player, entry.CropId, amount, "Harvest")
			if added <= 0 then
				return -- backpack full: keep the crop in the ground
			end
			setEntry(farm, tile, { TileId = tile.Id, State = "Tilled", Position = entry.Position })
			GameSoundService.PlayAt("Harvest", tile.Part.Position)
			VFXService.PlayAt("LeafBurst", tile.Part.Position + Vector3.new(0, 1, 0))
			DataService.Increment(player, { "Stats", "CropsHarvested" }, added)
			ProgressionService.Award(player, "HarvestCrop")
			FarmService.CropHarvested:Fire(player, entry.CropId, added)
		end)
		return
	end

	if not CropGrowth.IsWatered(entry) then
		local can = ToolService.EquipBestOfType(player, "WateringCan")
		if not can then
			Notify.Error(player, "You need a Watering Can.")
			return
		end
		AnimationService.PerformAction(player, "WaterPlant", "Water", function()
			if tile.Entry and tile.Entry.State == "Planted" and not CropGrowth.IsWatered(tile.Entry) then
				local watered = table.clone(tile.Entry)
				watered.WateredAt = os.time()
				setEntry(farm, tile, watered)
				Notify.Toast(player, ("%s watered! It grows %d%% faster now."):format(crop.DisplayName, math.floor((CropConfig.WaterSpeedMultiplier - 1) * 100)), "💧")
			end
		end)
		return
	end

	local remaining = CropGrowth.GetRemaining(entry, os.time())
	local stageName = CropConfig.Stages[CropGrowth.GetStage(entry, os.time())]
	Notify.Toast(player, ("%s · %s · ready in %s 💧"):format(crop.DisplayName, stageName, Format.Duration(remaining)), crop.Icon)
end

-- Seed picker result.
local function onPlantRequest(player: Player, tileId: any, seedId: any)
	if not Validate.Id(tileId) or not Validate.Id(seedId) then
		AntiExploitService.Flag(player, "BadPlantRequest", 2)
		return
	end
	local tile, farm = getTile(player, tileId)
	if not tile or not farm then
		return
	end
	if not nearTile(player, tile) then
		AntiExploitService.Flag(player, "PlantTooFar", 1)
		return
	end
	if not tile.Entry or tile.Entry.State ~= "Tilled" then
		return
	end
	if not CropConfig.SeedToCrop[seedId] or InventoryService.GetCount(player, seedId) < 1 then
		Notify.Error(player, "You don't have those seeds.")
		return
	end
	plant(player, farm, tile, seedId)
end

-- Admin/testing: finish every crop on the player's island.
function FarmService.GrowAll(player: Player)
	local island = IslandService.GetIsland(player)
	local farm = island and farms[island.Id]
	if not farm then
		return
	end
	for _, tile in farm.Tiles do
		local entry = tile.Entry
		if entry and entry.State == "Planted" then
			local crop = CropConfig.Crops[entry.CropId]
			local grown = table.clone(entry)
			grown.PlantedAt = os.time() - crop.GrowTime - 1
			grown.WateredAt = 0
			setEntry(farm, tile, grown)
		end
	end
end

function FarmService.Init()
	InteractionService.RegisterKind("FarmTile", {
		ActionText = "Till Soil",
		ObjectText = "Farm Tile",
		Permission = "Farm",
		MaxDistance = 8,
		Cooldown = 0.3,
		Handler = function(player: Player, part: Instance)
			local tile, farm = getTile(player, part:GetAttribute("TileId"))
			if tile and farm and tile.Part == part then
				onTileUsed(player, farm, tile)
			end
		end,
	})
	Net.OnServerEvent("PlantCropRequest", onPlantRequest)
end

function FarmService.Start()
	CropService.StageChanged:Connect(function(tile: any)
		refreshPrompt(tile)
	end)

	IslandService.IslandAssigned:Connect(function(player: Player, island: any)
		farms[island.Id] = { Island = island, Owner = player, Tiles = {}, Plots = {} }
		FarmService.RefreshFarm(player)
	end)
	IslandService.AreaUnlocked:Connect(function(player: Player)
		FarmService.RefreshFarm(player)
	end)
	IslandService.IslandReleased:Connect(function(_player: Player, islandId: string)
		farms[islandId] = nil
		CropService.UnregisterIsland(islandId)
	end)
end

return FarmService
