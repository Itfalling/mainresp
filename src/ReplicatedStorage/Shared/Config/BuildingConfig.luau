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
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local BuildingConfig = {
	RefundPercent = 0.5, -- deleting a building refunds this share of its cost

	Categories = {
		{ Id = "Homes", DisplayName = "Homes", Icon = "🏠" },
		{ Id = "Farm", DisplayName = "Farm", Icon = "🐄" },
		{ Id = "Utility", DisplayName = "Utility", Icon = "🧰" },
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
