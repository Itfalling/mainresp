--[[
	SCRIPT NAME:  DataSchema
	SCRIPT TYPE:  ModuleScript (server)
	WHERE:        ServerScriptService/Server/Data/DataSchema
	DEPENDENCIES: Shared.Config.GameConfig, ItemConfig, ToolConfig, IslandConfig,
	              ProgressionConfig, Shared.Util.TableUtil

	Defines the saved player profile, migrates old versions and REPAIRS bad
	data instead of wiping it (spec §146):
	  * missing keys are filled from the template,
	  * wrong types are reset (old value moved to Quarantine),
	  * unknown item/tool/area ids are moved to Quarantine — NOT deleted — and
	    are restored automatically if a later update re-adds that id,
	  * numbers are clamped to sane, finite, integer ranges.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.Config.GameConfig)
local ItemConfig = require(Shared.Config.ItemConfig)
local ToolConfig = require(Shared.Config.ToolConfig)
local IslandConfig = require(Shared.Config.IslandConfig)
local EconomyConfig = require(Shared.Config.EconomyConfig)
local ProgressionConfig = require(Shared.Config.ProgressionConfig)
local BuildingConfig = require(Shared.Config.BuildingConfig)
local CropConfig = require(Shared.Config.CropConfig)
local AnimalConfig = require(Shared.Config.AnimalConfig)
local QuestConfig = require(Shared.Config.QuestConfig)
local TableUtil = require(Shared.Util.TableUtil)

local DataSchema = {}

DataSchema.CurrentVersion = 2

-- Top-level keys never sent to the client.
DataSchema.PrivateKeys = table.freeze({ Quarantine = true })

local TEMPLATE = {
	Version = DataSchema.CurrentVersion,

	Coins = GameConfig.StartingCoins,
	Gems = GameConfig.StartingGems,
	XP = 0,
	Level = 1,

	Inventory = {
		Items = {}, -- [itemId] = count
		Capacity = GameConfig.Inventory.StartingCapacity,
		Favorites = {}, -- [itemId] = true
	},

	Tools = {
		Owned = {}, -- [toolId] = true
		Hotbar = {}, -- array of toolIds (<= ToolConfig.HotbarSize)
		Equipped = "", -- "" = nothing
		Durability = {}, -- [toolId] = number (optional system)
	},

	Island = {
		IslandId = "",
		Name = "",
		Level = GameConfig.StartingIslandLevel,
		XP = 0,
		Theme = IslandConfig.DefaultTheme,
		Permission = "Private", -- Private | Friends | Public (Phase 12)
		UnlockedAreas = { Starter = true },
		-- [uniqueId] = { BuildingId, UniqueId, Position = {X,Y,Z} (island-local), Rotation, Variant, State, Progress }
		Buildings = {},
		Decorations = {},
		-- [tileId] = { TileId, State = "Tilled"|"Planted", CropId, Position, PlantedAt, WateredAt }
		Crops = {},
		-- [uniqueId] = { AnimalId, UniqueId, Variant, HousingId, Happiness, HappinessAt, FedAt, ProduceReadyAt, PettedAt }
		Animals = {},
		FarmTiles = CropConfig.Farm.StarterTiles,
		Upgrades = { FarmTiles = 0, Capacity = 0 },
		Storage = {},
		Production = {}, -- Phase 8: production queues
		Likes = 0,
		Visits = 0,
	},

	Quests = { Current = QuestConfig.Chain[1], Progress = {}, Completed = {}, DailyResetAt = 0 },
	Achievements = {},
	Collection = { Fish = {}, Crops = {}, Animals = {}, Items = {} },
	Recipes = {},
	Cosmetics = { Owned = {}, Equipped = {} },

	Stats = {
		PlayTime = 0,
		WoodCollected = 0,
		StoneCollected = 0,
		CropsHarvested = 0,
		FishCaught = 0,
		AnimalsOwned = 0,
		MilkCollected = 0,
		EggsCollected = 0,
		ItemsSold = 0,
		CoinsEarned = 0,
		BuildingsBuilt = 0,
		AreasUnlocked = 0,
		QuestsCompleted = 0,
		RareItemsFound = 0,
	},

	Settings = { CameraShake = true, MusicVolume = 0.5, SfxVolume = 0.8 },

	Flags = {
		StarterChestClaimed = false,
		FirstEquip = false,
		TutorialStep = 0,
	},

	Meta = { CreatedAt = 0, LastSavedAt = 0, LastJoinAt = 0, JoinCount = 0 },

	-- Data we could not validate, kept instead of deleted.
	Quarantine = { Items = {}, Tools = {}, Areas = {}, Values = {}, Buildings = {}, Crops = {}, Animals = {} },
}

function DataSchema.Template()
	return TableUtil.DeepCopy(TEMPLATE)
end

-- version -> function(data) upgrading FROM that version to version + 1
local MIGRATIONS: { [number]: (any) -> () } = {
	-- v1 -> v2: first playable loop. Players who already opened the starter
	-- chest get the new starter tools + seeds; old quest layout is dropped.
	[1] = function(data)
		local flags = data.Flags
		if type(flags) == "table" and flags.StarterChestClaimed == true then
			if type(data.Tools) ~= "table" then
				data.Tools = {}
			end
			if type(data.Tools.Owned) ~= "table" then
				data.Tools.Owned = {}
			end
			if type(data.Tools.Hotbar) ~= "table" then
				data.Tools.Hotbar = {}
			end
			for _, toolId in GameConfig.StarterKit.Tools do
				if data.Tools.Owned[toolId] ~= true then
					data.Tools.Owned[toolId] = true
					table.insert(data.Tools.Hotbar, toolId)
				end
			end
			if type(data.Inventory) == "table" and type(data.Inventory.Items) == "table" then
				local seeds = tonumber(data.Inventory.Items.WheatSeeds) or 0
				data.Inventory.Items.WheatSeeds = seeds + (GameConfig.StarterKit.Items.WheatSeeds or 0)
			end
		end
		if type(data.Quests) == "table" then
			data.Quests.Active = nil
		end
		if type(data.Island) == "table" then
			for _, key in { "Buildings", "Crops", "Animals" } do
				if type(data.Island[key]) ~= "table" then
					data.Island[key] = {}
				end
			end
		end
	end,
}

local function isFiniteNumber(value: any): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

local function cleanInteger(value: any, min: number, max: number, fallback: number): number
	if not isFiniteNumber(value) then
		return fallback
	end
	return math.clamp(math.floor(value), min, max)
end

-- Recursively resets values whose type does not match the template.
local function repairTypes(data: { [any]: any }, template: { [any]: any }, quarantine: { [any]: any }, path: string)
	for key, templateValue in template do
		local value = data[key]
		if value ~= nil and type(value) ~= type(templateValue) then
			quarantine[path .. tostring(key)] = value
			data[key] = TableUtil.DeepCopy(templateValue)
		elseif type(templateValue) == "table" and type(value) == "table" and next(templateValue) ~= nil then
			-- Only recurse into "shaped" tables (non-empty template tables).
			repairTypes(value, templateValue, quarantine, path .. tostring(key) .. ".")
		end
	end
end

function DataSchema.Migrate(data: any): any
	local version = if isFiniteNumber(data.Version) then data.Version else 1
	while version < DataSchema.CurrentVersion do
		local migrate = MIGRATIONS[version]
		if migrate then
			migrate(data)
		end
		version += 1
	end
	data.Version = DataSchema.CurrentVersion
	return data
end

-- Returns a repaired profile table. Never returns nil for a table input.
function DataSchema.Sanitize(raw: any): any
	local data = if type(raw) == "table" then raw else DataSchema.Template()
	DataSchema.Migrate(data)
	if type(data.Quarantine) ~= "table" then
		data.Quarantine = TableUtil.DeepCopy(TEMPLATE.Quarantine)
	end
	if type(data.Quarantine.Values) ~= "table" then
		data.Quarantine.Values = {}
	end
	TableUtil.Reconcile(data, TEMPLATE)
	repairTypes(data, TEMPLATE, data.Quarantine.Values, "")

	-- Currencies / levels
	data.Coins = cleanInteger(data.Coins, 0, EconomyConfig.Currencies.Coins.Max, TEMPLATE.Coins)
	data.Gems = cleanInteger(data.Gems, 0, EconomyConfig.Currencies.Gems.Max, TEMPLATE.Gems)
	data.Level = cleanInteger(data.Level, 1, ProgressionConfig.Player.MaxLevel, 1)
	data.XP = cleanInteger(data.XP, 0, math.huge, 0)
	data.Island.Level = cleanInteger(data.Island.Level, 1, ProgressionConfig.Island.MaxLevel, 1)
	data.Island.XP = cleanInteger(data.Island.XP, 0, math.huge, 0)
	data.Inventory.Capacity = cleanInteger(data.Inventory.Capacity, GameConfig.Inventory.StartingCapacity, 1_000_000, GameConfig.Inventory.StartingCapacity)

	-- Restore quarantined ids that are valid again (e.g. an item re-added in an update).
	local quarantine = data.Quarantine
	for itemId, count in quarantine.Items do
		if ItemConfig.Exists(itemId) then
			data.Inventory.Items[itemId] = (data.Inventory.Items[itemId] or 0) + count
			quarantine.Items[itemId] = nil
		end
	end
	for toolId in quarantine.Tools do
		if ToolConfig.Get(toolId) then
			data.Tools.Owned[toolId] = true
			quarantine.Tools[toolId] = nil
		end
	end
	for areaId in quarantine.Areas do
		if IslandConfig.Areas[areaId] then
			data.Island.UnlockedAreas[areaId] = true
			quarantine.Areas[areaId] = nil
		end
	end

	-- Inventory items
	for itemId, count in data.Inventory.Items do
		if not isFiniteNumber(count) or count <= 0 then
			data.Inventory.Items[itemId] = nil
		elseif not ItemConfig.Exists(itemId) then
			quarantine.Items[tostring(itemId)] = math.floor(count)
			data.Inventory.Items[itemId] = nil
		else
			data.Inventory.Items[itemId] = math.min(math.floor(count), GameConfig.Inventory.MaxStack)
		end
	end
	for itemId in data.Inventory.Favorites do
		if not ItemConfig.Exists(itemId) then
			data.Inventory.Favorites[itemId] = nil
		end
	end

	-- Tools
	for toolId, owned in data.Tools.Owned do
		if owned ~= true then
			data.Tools.Owned[toolId] = nil
		elseif not ToolConfig.Get(toolId) then
			quarantine.Tools[tostring(toolId)] = true
			data.Tools.Owned[toolId] = nil
		end
	end
	local hotbar = {}
	local seen = {}
	for _, toolId in data.Tools.Hotbar do
		if #hotbar >= ToolConfig.HotbarSize then
			break
		end
		if type(toolId) == "string" and data.Tools.Owned[toolId] and not seen[toolId] then
			seen[toolId] = true
			table.insert(hotbar, toolId)
		end
	end
	data.Tools.Hotbar = hotbar
	if data.Tools.Equipped ~= "" and not data.Tools.Owned[data.Tools.Equipped] then
		data.Tools.Equipped = ""
	end

	-- Island areas
	for areaId, unlocked in data.Island.UnlockedAreas do
		if unlocked ~= true then
			data.Island.UnlockedAreas[areaId] = nil
		elseif not IslandConfig.Areas[areaId] then
			quarantine.Areas[tostring(areaId)] = true
			data.Island.UnlockedAreas[areaId] = nil
		end
	end
	data.Island.UnlockedAreas.Starter = true
	if type(data.Island.Name) ~= "string" or #data.Island.Name > IslandConfig.NameMaxLength * 4 then
		data.Island.Name = ""
	end

	local maxTiles = CropConfig.Farm.Columns * CropConfig.Farm.Rows
	data.Island.FarmTiles = cleanInteger(data.Island.FarmTiles, CropConfig.Farm.StarterTiles, maxTiles, CropConfig.Farm.StarterTiles)
	data.Island.Upgrades.FarmTiles = cleanInteger(data.Island.Upgrades.FarmTiles, 0, 100, 0)
	data.Island.Upgrades.Capacity = cleanInteger(data.Island.Upgrades.Capacity, 0, 100, 0)

	DataSchema.SanitizeIsland(data)
	DataSchema.SanitizeQuests(data)
	return data
end

local function validPosition(position: any): boolean
	return type(position) == "table"
		and isFiniteNumber(position.X)
		and isFiniteNumber(position.Y)
		and isFiniteNumber(position.Z)
		and math.abs(position.X) < 2000
		and math.abs(position.Z) < 2000
		and math.abs(position.Y) < 500
end

local function validBuilding(entry: any): boolean
	if type(entry) ~= "table" then
		return false
	end
	local def = BuildingConfig.Get(entry.BuildingId)
	if not def or not validPosition(entry.Position) then
		return false
	end
	if entry.Rotation ~= 0 and entry.Rotation ~= 90 and entry.Rotation ~= 180 and entry.Rotation ~= 270 then
		return false
	end
	return true
end

local function validCrop(key: any, entry: any, now: number): boolean
	if type(key) ~= "string" or not string.match(key, "^%u%d+$") or type(entry) ~= "table" then
		return false
	end
	if entry.State == "Tilled" then
		return true
	end
	if entry.State ~= "Planted" or not CropConfig.Crops[entry.CropId] then
		return false
	end
	return isFiniteNumber(entry.PlantedAt) and entry.PlantedAt <= now + 120
end

local function validAnimal(entry: any): boolean
	return type(entry) == "table" and AnimalConfig.Animals[entry.AnimalId] ~= nil
end

-- Buildings / crops / animals: repair what we can, quarantine the rest.
function DataSchema.SanitizeIsland(data: any)
	local island = data.Island
	local quarantine = data.Quarantine
	local now = os.time()

	-- Give back quarantined entries that became valid again.
	for key, entry in quarantine.Buildings do
		if validBuilding(entry) and island.Buildings[key] == nil then
			island.Buildings[key] = entry
			quarantine.Buildings[key] = nil
		end
	end

	for key, entry in island.Buildings do
		if type(key) == "string" and validBuilding(entry) then
			local steps = BuildingConfig.Get(entry.BuildingId).Steps
			entry.UniqueId = key
			entry.Variant = if type(entry.Variant) == "string" then entry.Variant else "Default"
			entry.Progress = cleanInteger(entry.Progress, 0, steps, 0)
			entry.State = if entry.State == "Complete" or entry.Progress >= steps then "Complete" else "Constructing"
		else
			quarantine.Buildings[tostring(key)] = entry
			island.Buildings[key] = nil
		end
	end

	for key, entry in island.Crops do
		if validCrop(key, entry, now) then
			entry.TileId = key
			if entry.State == "Planted" then
				entry.WateredAt = if isFiniteNumber(entry.WateredAt) then entry.WateredAt else 0
			else
				entry.CropId = nil
				entry.PlantedAt = nil
				entry.WateredAt = nil
			end
		else
			quarantine.Crops[tostring(key)] = entry
			island.Crops[key] = nil
		end
	end

	for key, entry in island.Animals do
		if type(key) == "string" and validAnimal(entry) then
			entry.UniqueId = key
			entry.Happiness = math.clamp(if isFiniteNumber(entry.Happiness) then entry.Happiness else AnimalConfig.StartHappiness, 0, 100)
			entry.HappinessAt = if isFiniteNumber(entry.HappinessAt) then entry.HappinessAt else now
			entry.FedAt = if isFiniteNumber(entry.FedAt) then entry.FedAt else 0
			entry.ProduceReadyAt = if isFiniteNumber(entry.ProduceReadyAt) then entry.ProduceReadyAt else 0
			entry.PettedAt = if isFiniteNumber(entry.PettedAt) then entry.PettedAt else 0
			entry.Variant = if type(entry.Variant) == "string" then entry.Variant else "Default"
			entry.HousingId = if type(entry.HousingId) == "string" then entry.HousingId else ""
		else
			quarantine.Animals[tostring(key)] = entry
			island.Animals[key] = nil
		end
	end
end

function DataSchema.SanitizeQuests(data: any)
	local quests = data.Quests
	if quests.Current ~= "" and not QuestConfig.Quests[quests.Current] then
		quests.Current = ""
	end
	-- A player who finished (or never started) the chain resumes at the first unfinished quest.
	if quests.Current == "" then
		for _, questId in QuestConfig.Chain do
			if quests.Completed[questId] ~= true then
				quests.Current = questId
				break
			end
		end
	end
	for key, value in quests.Progress do
		if type(key) ~= "string" or not isFiniteNumber(value) then
			quests.Progress[key] = nil
		end
	end
	for key, value in quests.Completed do
		if value ~= true then
			quests.Completed[key] = nil
		end
	end
end

-- Final guard before anything is written to the DataStore.
function DataSchema.IsSaveable(data: any): (boolean, string?)
	if type(data) ~= "table" then
		return false, "profile is not a table"
	end
	if data.Version ~= DataSchema.CurrentVersion then
		return false, "unexpected version"
	end
	if not isFiniteNumber(data.Coins) or data.Coins < 0 then
		return false, "invalid Coins"
	end
	if type(data.Inventory) ~= "table" or type(data.Inventory.Items) ~= "table" then
		return false, "invalid Inventory"
	end
	if type(data.Island) ~= "table" or type(data.Island.UnlockedAreas) ~= "table" then
		return false, "invalid Island"
	end
	return true, nil
end

return DataSchema
