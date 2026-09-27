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
local TableUtil = require(Shared.Util.TableUtil)

local DataSchema = {}

DataSchema.CurrentVersion = 1

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
		Buildings = {}, -- Phase 3: { BuildingId, UniqueId, Position = {X,Y,Z}, Rotation, Variant }
		Decorations = {},
		Crops = {}, -- Phase 4: { CropId, Position, PlantedAt, GrowthStage, Watered }
		Animals = {}, -- Phase 6: { AnimalId, UniqueId, Position, Happiness, Hunger, ProduceReadyAt }
		Storage = {},
		Production = {}, -- Phase 8: production queues
		Likes = 0,
		Visits = 0,
	},

	Quests = { Active = {}, Completed = {}, DailyResetAt = 0 },
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
	Quarantine = { Items = {}, Tools = {}, Areas = {}, Values = {} },
}

function DataSchema.Template()
	return TableUtil.DeepCopy(TEMPLATE)
end

-- version -> function(data) upgrading FROM that version to version + 1
local MIGRATIONS: { [number]: (any) -> () } = {
	-- [1] = function(data) data.NewField = ... end,
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

	return data
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
