--[[
	SCRIPT NAME:  ShopConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/ShopConfig
	DEPENDENCIES: CropConfig, AnimalConfig, Shared.Util.TableUtil

	Everything the island market sells. Seeds and animals are generated from
	CropConfig / AnimalConfig so prices live in exactly one place.

		Price       coins per purchase
		Items       extra item cost (tool upgrades)
		Grant       { Item = id, Amount } | { Tool = id } | { Animal = id } | { Upgrade = id, Amount }
		UnlockLevel island level required
		MaxOwned    for upgrades: how many times it can be bought
		Bulk        seeds can be bought in bundles of this size too

	Selling uses item SellValue (ItemConfig) x EconomyConfig multipliers x market demand.
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)
local CropConfig = require(script.Parent.CropConfig)
local AnimalConfig = require(script.Parent.AnimalConfig)

local ShopConfig = {
	MarketRange = 30, -- player must be this close to their market stall to trade

	Categories = {
		{ Id = "Seeds", DisplayName = "Seeds", Icon = "🌱" },
		{ Id = "Animals", DisplayName = "Animals", Icon = "🐄" },
		{ Id = "Tools", DisplayName = "Tools", Icon = "🪓" },
		{ Id = "Upgrades", DisplayName = "Upgrades", Icon = "⬆️" },
	},

	-- Item categories the "Sell Everything" button sells (never seeds or tools).
	SellAllCategories = { Crops = true, Fish = true, AnimalProducts = true },

	Items = {
		-- TOOLS
		WoodenBucket = { Category = "Tools", DisplayName = "Wooden Bucket", Icon = "🪣", Price = 20, Grant = { Tool = "WoodenBucket" }, UnlockLevel = 1, Order = 1, Description = "Needed to milk cows." },
		WoodenShovel = { Category = "Tools", DisplayName = "Wooden Shovel", Icon = "🪏", Price = 40, Grant = { Tool = "WoodenShovel" }, UnlockLevel = 1, Order = 2, Description = "Dig clay by the river." },
		StoneAxe = { Category = "Tools", DisplayName = "Stone Axe", Icon = "🪓", Price = 150, Items = { Stone = 15 }, Grant = { Tool = "StoneAxe" }, UnlockLevel = 2, Order = 3, Description = "Chops trees in 2 hits instead of 4." },
		StonePickaxe = { Category = "Tools", DisplayName = "Stone Pickaxe", Icon = "⛏️", Price = 150, Items = { Stone = 15 }, Grant = { Tool = "StonePickaxe" }, UnlockLevel = 2, Order = 4, Description = "Mines faster and can break Iron deposits." },
		IronFishingRod = { Category = "Tools", DisplayName = "Iron Fishing Rod", Icon = "🎣", Price = 500, Items = { Wood = 20 }, Grant = { Tool = "IronFishingRod" }, UnlockLevel = 4, Order = 5, Description = "Faster bites and better luck with rare fish." },
		IronAxe = { Category = "Tools", DisplayName = "Iron Axe", Icon = "🪓", Price = 800, Items = { Iron = 10 }, Grant = { Tool = "IronAxe" }, UnlockLevel = 5, Order = 6, Description = "Cuts through Ancient Trees." },
		IronPickaxe = { Category = "Tools", DisplayName = "Iron Pickaxe", Icon = "⛏️", Price = 800, Items = { Iron = 10 }, Grant = { Tool = "IronPickaxe" }, UnlockLevel = 5, Order = 7, Description = "Mines Crystal clusters." },

		-- UPGRADES
		BiggerBackpack = { Category = "Upgrades", DisplayName = "Bigger Backpack", Icon = "🎒", Price = 150, Grant = { Upgrade = "Capacity", Amount = 100 }, MaxOwned = 5, UnlockLevel = 1, Order = 2, Description = "+100 backpack capacity." },
	},
}

for index, cropId in CropConfig.Order do
	local crop = CropConfig.Crops[cropId]
	ShopConfig.Items[crop.Seed] = {
		Category = "Seeds",
		DisplayName = crop.DisplayName .. " Seeds",
		Icon = crop.Icon,
		Price = crop.SeedCost,
		Grant = { Item = crop.Seed, Amount = 1 },
		Bulk = 5,
		UnlockLevel = crop.UnlockLevel,
		Order = index,
		Description = ("Grows in %ds · %d-%d %s per harvest · sells for %d 🪙 each"):format(
			crop.GrowTime,
			crop.Yield.Min,
			crop.Yield.Max,
			crop.DisplayName,
			crop.SellValue
		),
	}
end

for index, animalId in AnimalConfig.Order do
	local animal = AnimalConfig.Animals[animalId]
	ShopConfig.Items[animalId] = {
		Category = "Animals",
		DisplayName = animal.DisplayName,
		Icon = animal.Icon,
		Price = animal.Price,
		Grant = { Animal = animalId },
		UnlockLevel = animal.UnlockLevel,
		Order = index,
		Description = ("Needs a %s. Eats %s, gives %s."):format(animal.Housing, animal.Food, animal.Produce),
	}
end

for itemId, def in ShopConfig.Items do
	def.Id = itemId
end

return TableUtil.DeepFreeze(ShopConfig)
