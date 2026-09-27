--[[
	SCRIPT NAME:  IslandConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/IslandConfig
	DEPENDENCIES: Shared.Util.TableUtil

	Island geometry, server slots, starter layout and expansion areas.

	COORDINATES: everything here is ISLAND-LOCAL. (0, 0) is the centre of the
	starter island at sea level. +Z is the "front" of the island (spawn + dock
	side, always open ocean). Saved building/crop/animal positions are also
	island-local, so an island can load into any slot on any server.

	EXPANSION AREAS are circular land lobes attached to the starter island.
	`Angle` is measured in degrees from +Z towards +X. A locked area shows an
	underwater sandbar and a 🔒 sign on the starter shore; unlocking it raises
	the land (IslandService.TryUnlockArea).
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local IslandConfig = {
	SeaLevel = 0,
	SurfaceHeight = 6, -- grass height above sea level
	BeachHeight = 3,
	ShallowsHeight = 1.5,
	BeachWidth = 6,
	ShallowsWidth = 14,
	SandbarDepth = 4, -- how far below the surface a locked area's sandbar sits
	LandDepth = 24, -- how deep island terrain extends below sea level

	-- Server slot grid. Islands are SlotSpacing studs apart so they never touch.
	SlotSpacing = 1000,
	SlotsPerRow = 4,

	BuildMargin = 4, -- keep builds this far inside area edges
	DefaultNameFormat = "%s's Island",
	NameMaxLength = 24,
	DefaultTheme = "Tropical",

	-- Order matters: it is the unlock progression shown in the UI.
	AreaOrder = { "Starter", "Forest", "Farm", "River", "Beach", "Mountain", "StarfallCove", "Mainland" },

	Areas = {
		Starter = {
			DisplayName = "Starter Island",
			Angle = 0,
			Distance = 0,
			Radius = 70,
			Biome = "Meadow",
			Unlock = nil,
			Reward = "Your home. Trees, rocks, a farm plot and a dock to fish from.",
		},
		Forest = {
			DisplayName = "Whispering Forest",
			Angle = 300,
			Distance = 112,
			Radius = 55,
			Biome = "Forest",
			Unlock = { Coins = 500, IslandLevel = 2 },
			Reward = "Dense woods: hardwood trees, fiber bushes and berries.",
		},
		Farm = {
			DisplayName = "Sunny Fields",
			Angle = 60,
			Distance = 112,
			Radius = 55,
			Biome = "Meadow",
			Unlock = { Coins = 1500, IslandLevel = 4, RequiresArea = "Forest" },
			Reward = "Wide flat fields for big farms and animal pastures.",
		},
		River = {
			DisplayName = "Willow River",
			Angle = 100,
			Distance = 115,
			Radius = 55,
			Biome = "River",
			Unlock = { Coins = 4000, IslandLevel = 7, RequiresArea = "Farm" },
			Reward = "Better fishing, riverbank clay and water pumps.",
		},
		Beach = {
			DisplayName = "Coral Beach",
			Angle = 260,
			Distance = 115,
			Radius = 55,
			Biome = "Beach",
			Unlock = { Coins = 8000, IslandLevel = 10, RequiresArea = "River" },
			Reward = "Ocean fishing, sand, shells and rare fish.",
		},
		Mountain = {
			DisplayName = "Stonepeak Mountain",
			Angle = 220,
			Distance = 120,
			Radius = 62,
			Biome = "Mountain",
			Unlock = { Coins = 15000, IslandLevel = 14, RequiresArea = "Beach" },
			Reward = "Stone, iron and copper ore — the key to better tools.",
		},
		StarfallCove = {
			DisplayName = "Starfall Cove",
			Angle = 140,
			Distance = 120,
			Radius = 55,
			Biome = "Cave",
			Unlock = { Coins = 40000, IslandLevel = 20, RequiresArea = "Mountain" },
			Reward = "A hidden cave with crystals, gold and epic fish.",
		},
		Mainland = {
			DisplayName = "Great Mainland",
			Angle = 180,
			Distance = 140,
			Radius = 85,
			Biome = "Meadow",
			Unlock = { Coins = 100000, IslandLevel = 30, RequiresArea = "StarfallCove" },
			Reward = "A huge stretch of land for your grandest builds.",
		},
	},

	-- Starter island layout (island-local XZ; Y is found by raycasting terrain).
	StarterLayout = {
		Spawn = Vector2.new(0, 40),
		SpawnFacing = Vector2.new(0, -1), -- look towards the island centre
		StarterChest = Vector2.new(-9, 28),
		IslandSign = Vector2.new(9, 31),
		HousePlot = { Center = Vector2.new(-24, -6), Size = Vector2.new(26, 22) },
		FarmPlot = { Center = Vector2.new(26, -2), Size = Vector2.new(20, 16) },
		Dock = { Start = Vector2.new(12, 76), Length = 32, Width = 8 },
		Hills = {
			{ Center = Vector2.new(0, -38), Radius = 16, Height = 5 },
		},
		Palms = {
			Vector2.new(19, 52),
			Vector2.new(-23, 50),
			Vector2.new(44, 10),
			Vector2.new(-42, 22),
			Vector2.new(-16, -48),
			Vector2.new(17, -46),
		},
		FlowerPatches = {
			Vector2.new(-4, 14),
			Vector2.new(12, 18),
			Vector2.new(-36, 8),
			Vector2.new(38, 22),
		},
	},
}

return TableUtil.DeepFreeze(IslandConfig)
