--[[
	SCRIPT NAME:  ItemConfig
	SCRIPT TYPE:  ModuleScript (shared config / registry)
	WHERE:        ReplicatedStorage/Shared/Config/ItemConfig
	DEPENDENCIES: ResourceConfig, RarityConfig, Shared.Util.TableUtil

	The ONE registry of inventory item IDs. InventoryService refuses any ID not
	found here, and DataSchema quarantines unknown IDs in saved data.

	Adding a new item source in a later phase:
		1. Create e.g. CropConfig with an `Items` table in the same shape.
		2. Add it to SOURCES below.
	Nothing else needs to change.
]]

local Config = script.Parent
local TableUtil = require(script.Parent.Parent.Util.TableUtil)
local RarityConfig = require(Config.RarityConfig)

local SOURCES = {
	require(Config.ResourceConfig),
	require(Config.CropConfig),
	require(Config.FishConfig),
	require(Config.AnimalConfig),
	-- Phase 8: require(Config.RecipeConfig),
}

export type ItemDef = {
	Id: string,
	DisplayName: string,
	Category: string,
	Rarity: string,
	SellValue: number,
	Icon: string,
	Image: string?,
	Description: string,
	MaxStack: number?,
}

local ItemConfig = {
	-- Inventory tabs, in display order.
	Categories = {
		{ Id = "All", DisplayName = "All", Icon = "🎒" },
		{ Id = "Resources", DisplayName = "Resources", Icon = "🪵" },
		{ Id = "Crops", DisplayName = "Crops", Icon = "🌽" },
		{ Id = "Seeds", DisplayName = "Seeds", Icon = "🌱" },
		{ Id = "Fish", DisplayName = "Fish", Icon = "🐟" },
		{ Id = "AnimalProducts", DisplayName = "Animal", Icon = "🥛" },
		{ Id = "Materials", DisplayName = "Materials", Icon = "⛏️" },
		{ Id = "Crafted", DisplayName = "Crafted", Icon = "🍞" },
		{ Id = "Tools", DisplayName = "Tools", Icon = "🪓" },
		{ Id = "Decorations", DisplayName = "Decor", Icon = "🌸" },
	},
	Items = {} :: { [string]: ItemDef },
}

for _, source in SOURCES do
	for id, def in source.Items do
		assert(ItemConfig.Items[id] == nil, "Duplicate item id: " .. id)
		assert(RarityConfig.Rarities[def.Rarity], "Unknown rarity on item " .. id)
		local item = table.clone(def)
		item.Id = id
		ItemConfig.Items[id] = item
	end
end

function ItemConfig.Get(itemId: string): ItemDef?
	return ItemConfig.Items[itemId]
end

function ItemConfig.Exists(itemId: any): boolean
	return type(itemId) == "string" and ItemConfig.Items[itemId] ~= nil
end

return TableUtil.DeepFreeze(ItemConfig)
