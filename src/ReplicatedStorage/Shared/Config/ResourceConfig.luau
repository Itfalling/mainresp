--[[
	SCRIPT NAME:  ResourceConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/ResourceConfig
	DEPENDENCIES: Shared.Util.TableUtil

	Raw gatherable resources. SellValue is the ONLY place the base price of a
	resource is defined (the market in Phase 7 reads it from ItemConfig).

	Icon: emoji used by the UI until real icon images exist. Image: optional
	Roblox image id (placeholder until you upload art).

	Future phases add their own item tables (CropConfig, FishConfig,
	AnimalConfig products, RecipeConfig outputs); ItemConfig merges them.
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local PLACEHOLDER_IMAGE = "rbxassetid://PLACEHOLDER"

local ResourceConfig = {
	Items = {
		-- COMMON
		Wood = { DisplayName = "Wood", Category = "Resources", Rarity = "Common", SellValue = 2, Icon = "🪵", Image = PLACEHOLDER_IMAGE, Description = "Sturdy logs chopped from island trees. The backbone of every build." },
		Stone = { DisplayName = "Stone", Category = "Resources", Rarity = "Common", SellValue = 3, Icon = "🪨", Image = PLACEHOLDER_IMAGE, Description = "Solid rock mined with a pickaxe. Used for foundations and tools." },
		Fiber = { DisplayName = "Fiber", Category = "Resources", Rarity = "Common", SellValue = 2, Icon = "🌾", Image = PLACEHOLDER_IMAGE, Description = "Tough plant fibers used for rope, nets and baskets." },
		Clay = { DisplayName = "Clay", Category = "Resources", Rarity = "Common", SellValue = 4, Icon = "🟫", Image = PLACEHOLDER_IMAGE, Description = "Soft riverbank clay. Fire it into bricks and pots." },
		Sand = { DisplayName = "Sand", Category = "Resources", Rarity = "Common", SellValue = 2, Icon = "⏳", Image = PLACEHOLDER_IMAGE, Description = "Fine beach sand. Glassmakers love it." },
		Water = { DisplayName = "Water", Category = "Resources", Rarity = "Common", SellValue = 1, Icon = "💧", Image = PLACEHOLDER_IMAGE, Description = "Fresh water from a well or pump. Crops and animals need it." },

		-- ADVANCED
		Iron = { DisplayName = "Iron Ore", Category = "Materials", Rarity = "Uncommon", SellValue = 12, Icon = "⛓️", Image = PLACEHOLDER_IMAGE, Description = "Ore from the mountain. Smelt it into iron tools." },
		Copper = { DisplayName = "Copper Ore", Category = "Materials", Rarity = "Uncommon", SellValue = 10, Icon = "🟠", Image = PLACEHOLDER_IMAGE, Description = "Shiny orange ore used for pipes and machinery." },
		Gold = { DisplayName = "Gold Ore", Category = "Materials", Rarity = "Rare", SellValue = 45, Icon = "🟡", Image = PLACEHOLDER_IMAGE, Description = "Precious ore buried deep in the mountain." },
		Crystal = { DisplayName = "Crystal", Category = "Materials", Rarity = "Epic", SellValue = 120, Icon = "💎", Image = PLACEHOLDER_IMAGE, Description = "A glowing crystal found only in island caves." },
		StarShard = { DisplayName = "Star Shard", Category = "Materials", Rarity = "Legendary", SellValue = 400, Icon = "🌟", Image = PLACEHOLDER_IMAGE, Description = "A fragment of a fallen star. Appears during meteor showers." },
		AncientWood = { DisplayName = "Ancient Wood", Category = "Materials", Rarity = "Epic", SellValue = 150, Icon = "🌳", Image = PLACEHOLDER_IMAGE, Description = "Timber from trees older than the island itself." },
	},
}

return TableUtil.DeepFreeze(ResourceConfig)
