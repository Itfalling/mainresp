--[[
	SCRIPT NAME:  BuildingConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/BuildingConfig
	DEPENDENCIES: Shared.Util.TableUtil

	Every placeable structure. Models are procedural (Shared/Building/
	BuildingModels) so the game runs with no uploaded meshes; each model part
	carries a Stage number so construction reveals the building piece by
	piece — one stage per hammer hit (Steps).

		Cost        { Coins, Items = { Wood = n, ... } } charged atomically by BuildService
		Footprint   Vector2 studs (X, Z) at rotation 0
		Height      used for overlap checks
		Steps       hammer hits to finish construction
		UnlockLevel island level required
		Capacity    housing: animals it holds, e.g. { Cow = 2 }
		CapacityBonus  backpack capacity added when complete
		Pen         housing: island-local offset of the animal pen centre + radius
		Steps = 0   instant (soil tiles, saplings, rocks): appears finished right away
		Node        places a harvestable resource node of this type instead of a model
		Hidden      not listed in the build menu (e.g. the market stall)
		Unique / NoDelete   one per island / can be moved but never removed
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local BuildingConfig = {
	RefundPercent = 0.5, -- deleting a building refunds this share of its cost

	Categories = {
		{ Id = "Homes", DisplayName = "Homes", Icon = "🏠" },
		{ Id = "Farm", DisplayName = "Farm", Icon = "🐄" },
		{ Id = "Utility", DisplayName = "Utility", Icon = "🧰" },
		{ Id = "Nature", DisplayName = "Nature", Icon = "🌳" },
		{ Id = "Decoration", DisplayName = "Decor", Icon = "🌸" },
	},

	Buildings = {
		-- HOMES
		SmallCottage = {
			Category = "Homes", DisplayName = "Small Cottage", Icon = "🏡", Order = 1,
			Description = "A cosy first home for your island.",
			Cost = { Coins = 100, Items = { Wood = 30, Stone = 10 } },
			Footprint = Vector2.new(10, 10), Height = 12, Steps = 6, UnlockLevel = 1,
		},
		WoodenCabin = {
			Category = "Homes", DisplayName = "Wooden Cabin", Icon = "🛖", Order = 2,
			Description = "A roomy log cabin with a front porch.",
			Cost = { Coins = 250, Items = { Wood = 60, Stone = 25, Fiber = 10 } },
			Footprint = Vector2.new(14, 12), Height = 13, Steps = 8, UnlockLevel = 3,
		},
		StoneHouse = {
			Category = "Homes", DisplayName = "Stone House", Icon = "🏘️", Order = 3,
			Description = "Solid stone walls built to last.",
			Cost = { Coins = 600, Items = { Stone = 80, Wood = 40, Iron = 5 } },
			Footprint = Vector2.new(14, 14), Height = 15, Steps = 10, UnlockLevel = 6,
		},

		-- FARM
		Barn = {
			Category = "Farm", DisplayName = "Barn", Icon = "🐄", Order = 1,
			Description = "Houses 2 cows. Required before you can buy a cow.",
			Cost = { Coins = 150, Items = { Wood = 40, Stone = 15 } },
			Footprint = Vector2.new(14, 22), Height = 13, Steps = 7, UnlockLevel = 1,
			Capacity = { Cow = 2 }, Pen = { Offset = Vector2.new(0, 5.5), Radius = 4.5 },
		},
		SoilTile = {
			Category = "Farm", DisplayName = "Soil Tile", Icon = "🟫", Order = 0,
			Description = "A 4x4 farm tile. Till it with a hoe, then plant seeds. Place as many as you like!",
			Cost = { Coins = 15, Items = {} },
			Footprint = Vector2.new(4, 4), Height = 1, Steps = 0, UnlockLevel = 1,
		},
		ChickenCoop = {
			Category = "Farm", DisplayName = "Chicken Coop", Icon = "🐔", Order = 2,
			Description = "Houses 4 chickens. Required before you can buy chickens.",
			Cost = { Coins = 80, Items = { Wood = 25, Fiber = 5 } },
			Footprint = Vector2.new(10, 14), Height = 8, Steps = 5, UnlockLevel = 1,
			Capacity = { Chicken = 4 }, Pen = { Offset = Vector2.new(0, 3.5), Radius = 3 },
		},

		-- UTILITY
		StorageChest = {
			Category = "Utility", DisplayName = "Storage Chest", Icon = "📦", Order = 1,
			Description = "+100 backpack capacity while it stands on your island.",
			Cost = { Coins = 60, Items = { Wood = 20 } },
			Footprint = Vector2.new(4, 4), Height = 4, Steps = 2, UnlockLevel = 1, CapacityBonus = 100,
		},
		Well = {
			Category = "Utility", DisplayName = "Stone Well", Icon = "🪣", Order = 2,
			Description = "A charming stone well for your village square.",
			Cost = { Coins = 40, Items = { Stone = 20, Wood = 5 } },
			Footprint = Vector2.new(6, 6), Height = 8, Steps = 3, UnlockLevel = 1,
		},

		MarketStall = {
			Category = "Utility", DisplayName = "Market Stall", Icon = "🛒", Order = 99,
			Description = "Sell your goods and shop here. Move it anywhere you like.",
			Cost = { Coins = 0, Items = {} },
			Footprint = Vector2.new(10, 7), Height = 10, Steps = 0, UnlockLevel = 1,
			Hidden = true, Unique = true, NoDelete = true,
		},

		-- NATURE (harvestable: they grow back after you chop / mine them)
		OakSapling = {
			Category = "Nature", DisplayName = "Oak Tree", Icon = "🌳", Order = 1,
			Description = "Plant your own oak tree. Chop it for wood — it grows back!",
			Cost = { Coins = 20, Items = { Wood = 2 } },
			Footprint = Vector2.new(6, 6), Height = 14, Steps = 0, UnlockLevel = 1, Node = "Tree",
		},
		PalmSapling = {
			Category = "Nature", DisplayName = "Palm Tree", Icon = "🌴", Order = 2,
			Description = "A breezy palm for your beach.",
			Cost = { Coins = 20, Items = { Wood = 2 } },
			Footprint = Vector2.new(6, 6), Height = 14, Steps = 0, UnlockLevel = 1, Node = "PalmTree",
		},
		PineSapling = {
			Category = "Nature", DisplayName = "Pine Tree", Icon = "🌲", Order = 3,
			Description = "A tall pine that drops extra wood.",
			Cost = { Coins = 30, Items = { Wood = 3 } },
			Footprint = Vector2.new(6, 6), Height = 16, Steps = 0, UnlockLevel = 2, Node = "PineTree",
		},
		MapleSapling = {
			Category = "Nature", DisplayName = "Maple Tree", Icon = "🍁", Order = 4,
			Description = "Blazing orange leaves all year round.",
			Cost = { Coins = 30, Items = { Wood = 3 } },
			Footprint = Vector2.new(6, 6), Height = 14, Steps = 0, UnlockLevel = 2, Node = "AutumnTree",
		},
		Boulder = {
			Category = "Nature", DisplayName = "Boulder", Icon = "🪨", Order = 5,
			Description = "A rock you can mine again and again.",
			Cost = { Coins = 25, Items = { Stone = 4 } },
			Footprint = Vector2.new(5, 5), Height = 5, Steps = 0, UnlockLevel = 1, Node = "Rock",
		},
		FiberPlant = {
			Category = "Nature", DisplayName = "Fiber Bush", Icon = "🌿", Order = 6,
			Description = "Pick fiber by hand. Regrows quickly.",
			Cost = { Coins = 10, Items = {} },
			Footprint = Vector2.new(4, 4), Height = 4, Steps = 0, UnlockLevel = 1, Node = "FiberBush",
		},

		-- DECORATION
		WoodenFence = {
			Category = "Decoration", DisplayName = "Wooden Fence", Icon = "🚧", Order = 1,
			Description = "Line your fields and paths.",
			Cost = { Coins = 0, Items = { Wood = 4 } },
			Footprint = Vector2.new(4, 1), Height = 4, Steps = 1, UnlockLevel = 1,
		},
		StonePath = {
			Category = "Decoration", DisplayName = "Stone Path", Icon = "🪨", Order = 2,
			Description = "A tidy stone path tile.",
			Cost = { Coins = 0, Items = { Stone = 3 } },
			Footprint = Vector2.new(4, 4), Height = 1, Steps = 1, UnlockLevel = 1,
		},
		Bench = {
			Category = "Decoration", DisplayName = "Bench", Icon = "🪑", Order = 3,
			Description = "Take a break and admire your island.",
			Cost = { Coins = 5, Items = { Wood = 8 } },
			Footprint = Vector2.new(6, 2), Height = 4, Steps = 1, UnlockLevel = 1,
		},
		FlowerBed = {
			Category = "Decoration", DisplayName = "Flower Bed", Icon = "🌷", Order = 4,
			Description = "A splash of colour.",
			Cost = { Coins = 10, Items = { Fiber = 4 } },
			Footprint = Vector2.new(4, 4), Height = 3, Steps = 1, UnlockLevel = 1,
		},
		Lantern = {
			Category = "Decoration", DisplayName = "Lantern", Icon = "🏮", Order = 5,
			Description = "A warm light for evening strolls.",
			Cost = { Coins = 10, Items = { Wood = 3, Stone = 2 } },
			Footprint = Vector2.new(2, 2), Height = 7, Steps = 1, UnlockLevel = 1,
		},
		Campfire = {
			Category = "Decoration", DisplayName = "Campfire", Icon = "🔥", Order = 6,
			Description = "Crackling and cosy.",
			Cost = { Coins = 0, Items = { Wood = 6, Stone = 6 } },
			Footprint = Vector2.new(4, 4), Height = 3, Steps = 2, UnlockLevel = 1,
		},
	},
}

for buildingId, def in BuildingConfig.Buildings do
	def.Id = buildingId
	def.Cost.Items = def.Cost.Items or {}
end

function BuildingConfig.Get(buildingId: any)
	if type(buildingId) ~= "string" then
		return nil
	end
	return BuildingConfig.Buildings[buildingId]
end

return TableUtil.DeepFreeze(BuildingConfig)
