--[[
	SCRIPT NAME:  CropConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/CropConfig
	DEPENDENCIES: Shared.Util.TableUtil

	Every crop and the farm plot layout. Growth is DATA-DRIVEN and computed
	from server timestamps (Shared/Util/CropGrowth), so crops keep growing
	while the player is offline and nothing ticks per frame.

	Per crop:
		SeedCost      shop price per seed
		GrowTime      seconds from planting to harvestable (unwatered)
		Yield         {Min, Max} produce per harvest
		SellValue     base market price of one produce item
		UnlockLevel   island level required to buy the seed
		Shape         visual style: Grain | Root | Tall | Bush

	Generated items: "<Crop>" (Category Crops) and "<Crop>Seeds" (Category Seeds).
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local CropConfig = {
	-- Watering multiplies growth speed from the moment it is watered.
	WaterSpeedMultiplier = 1.5,

	Stages = { "Seed", "Sprout", "Small Plant", "Growing", "Mature", "Harvestable" },

	Farm = {
		TileSize = 4,
		TileGap = 0.8,
		Columns = 4,
		Rows = 3,
		StarterTiles = 6, -- tiles usable on a new island (the shop sells more, up to Columns x Rows)
	},

	Crops = {
		Wheat = {
			DisplayName = "Wheat", Icon = "🌾", SeedCost = 5, GrowTime = 60, Yield = { Min = 2, Max = 3 }, SellValue = 8,
			UnlockLevel = 1, Shape = "Grain", Rarity = "Common",
			StalkColor = Color3.fromRGB(150, 190, 70), ProduceColor = Color3.fromRGB(235, 200, 90),
			Description = "Golden grain. Sell it, or feed it to your animals.",
		},
		Carrot = {
			DisplayName = "Carrot", Icon = "🥕", SeedCost = 10, GrowTime = 120, Yield = { Min = 2, Max = 3 }, SellValue = 16,
			UnlockLevel = 1, Shape = "Root", Rarity = "Common",
			StalkColor = Color3.fromRGB(80, 170, 60), ProduceColor = Color3.fromRGB(255, 140, 40),
			Description = "Crunchy and orange. Grows underground.",
		},
		Potato = {
			DisplayName = "Potato", Icon = "🥔", SeedCost = 15, GrowTime = 150, Yield = { Min = 3, Max = 4 }, SellValue = 14,
			UnlockLevel = 2, Shape = "Root", Rarity = "Common",
			StalkColor = Color3.fromRGB(90, 160, 70), ProduceColor = Color3.fromRGB(190, 150, 95),
			Description = "A hearty island staple.",
		},
		Corn = {
			DisplayName = "Corn", Icon = "🌽", SeedCost = 20, GrowTime = 180, Yield = { Min = 2, Max = 3 }, SellValue = 30,
			UnlockLevel = 3, Shape = "Tall", Rarity = "Uncommon",
			StalkColor = Color3.fromRGB(110, 180, 60), ProduceColor = Color3.fromRGB(250, 215, 60),
			Description = "Tall stalks with sweet golden cobs.",
		},
		SugarCane = {
			DisplayName = "Sugar Cane", Icon = "🎋", SeedCost = 25, GrowTime = 200, Yield = { Min = 3, Max = 4 }, SellValue = 26,
			UnlockLevel = 4, Shape = "Tall", Rarity = "Uncommon",
			StalkColor = Color3.fromRGB(130, 190, 90), ProduceColor = Color3.fromRGB(200, 230, 150),
			Description = "Sweet stalks bakers love.",
		},
		Tomato = {
			DisplayName = "Tomato", Icon = "🍅", SeedCost = 30, GrowTime = 240, Yield = { Min = 3, Max = 5 }, SellValue = 32,
			UnlockLevel = 5, Shape = "Bush", Rarity = "Uncommon",
			StalkColor = Color3.fromRGB(70, 150, 60), ProduceColor = Color3.fromRGB(230, 50, 45),
			Description = "Juicy red tomatoes on a leafy vine.",
		},
		Strawberry = {
			DisplayName = "Strawberry", Icon = "🍓", SeedCost = 45, GrowTime = 300, Yield = { Min = 4, Max = 6 }, SellValue = 36,
			UnlockLevel = 6, Shape = "Bush", Rarity = "Rare",
			StalkColor = Color3.fromRGB(60, 150, 70), ProduceColor = Color3.fromRGB(240, 40, 80),
			Description = "Sweet berries worth waiting for.",
		},
	},

	-- Display order in shops / seed picker.
	Order = { "Wheat", "Carrot", "Potato", "Corn", "SugarCane", "Tomato", "Strawberry" },

	Items = {} :: { [string]: any },
	SeedToCrop = {} :: { [string]: string },
}

for cropId, crop in CropConfig.Crops do
	local seedId = cropId .. "Seeds"
	crop.Id = cropId
	crop.Seed = seedId
	CropConfig.SeedToCrop[seedId] = cropId
	CropConfig.Items[cropId] = {
		DisplayName = crop.DisplayName,
		Category = "Crops",
		Rarity = crop.Rarity,
		SellValue = crop.SellValue,
		Icon = crop.Icon,
		Description = crop.Description,
	}
	CropConfig.Items[seedId] = {
		DisplayName = crop.DisplayName .. " Seeds",
		Category = "Seeds",
		Rarity = "Common",
		SellValue = math.max(1, math.floor(crop.SeedCost / 2)),
		Icon = "🌱",
		Description = ("Plant on a tilled farm tile. Grows %s in %ds."):format(crop.DisplayName, crop.GrowTime),
	}
end

return TableUtil.DeepFreeze(CropConfig)
