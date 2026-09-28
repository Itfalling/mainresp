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

	AREA CONTENT gives every expansion a reason to exist (spec §120):
	resource nodes to gather, a fishing zone, or a second farm plot.

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
			Content = { FishingZone = "Shore" }, -- trees/rocks/bushes are hand-placed in StarterLayout
		},
		Forest = {
			DisplayName = "Whispering Forest",
			Angle = 300,
			Distance = 112,
			Radius = 55,
			Biome = "Forest",
			Unlock = { Coins = 500, IslandLevel = 2 },
			Reward = "Dense woods full of pine trees and fiber bushes.",
			Content = { Nodes = { PineTree = 8, Tree = 3, FiberBush = 5 } },
		},
		Farm = {
			DisplayName = "Sunny Fields",
			Angle = 60,
			Distance = 112,
			Radius = 55,
			Biome = "Meadow",
			Unlock = { Coins = 1500, IslandLevel = 4, RequiresArea = "Forest" },
			Reward = "A second 12-tile farm plot on wide, flat fields.",
			Content = { Nodes = { Tree = 2, FiberBush = 2 }, FarmPlot = true },
		},
		River = {
			DisplayName = "Willow River",
			Angle = 100,
			Distance = 115,
			Radius = 55,
			Biome = "River",
			Unlock = { Coins = 4000, IslandLevel = 7, RequiresArea = "Farm" },
			Reward = "River fishing (trout & salmon) and riverbank clay.",
			Content = { Nodes = { ClayPatch = 5, Tree = 2 }, FishingZone = "River" },
		},
		Beach = {
			DisplayName = "Coral Beach",
			Angle = 260,
			Distance = 115,
			Radius = 55,
			Biome = "Beach",
			Unlock = { Coins = 8000, IslandLevel = 10, RequiresArea = "River" },
			Reward = "Ocean fishing (tuna, swordfish) and sand piles.",
			Content = { Nodes = { SandPile = 6, FiberBush = 2 }, FishingZone = "Ocean" },
		},
		Mountain = {
			DisplayName = "Stonepeak Mountain",
			Angle = 220,
			Distance = 120,
			Radius = 62,
			Biome = "Mountain",
			Unlock = { Coins = 15000, IslandLevel = 14, RequiresArea = "Beach" },
			Reward = "Rocks and iron deposits — the key to better tools.",
			Content = { Nodes = { Rock = 6, IronRock = 5 } },
		},
		StarfallCove = {
			DisplayName = "Starfall Cove",
			Angle = 140,
			Distance = 120,
			Radius = 55,
			Biome = "Cave",
			Unlock = { Coins = 40000, IslandLevel = 20, RequiresArea = "Mountain" },
			Reward = "Crystal clusters and an epic cave fishing pool.",
			Content = { Nodes = { CrystalRock = 4, IronRock = 2 }, FishingZone = "Cave" },
		},
		Mainland = {
			DisplayName = "Great Mainland",
			Angle = 180,
			Distance = 140,
			Radius = 85,
			Biome = "Meadow",
			Unlock = { Coins = 100000, IslandLevel = 30, RequiresArea = "StarfallCove" },
			Reward = "Huge build space plus ancient trees.",
			Content = { Nodes = { Tree = 6, PineTree = 4, Rock = 5, AncientTree = 3 } },
		},
	},

	-- Starter island layout (island-local XZ; Y is found by raycasting terrain).
	StarterLayout = {
		Spawn = Vector2.new(0, 40),
		SpawnFacing = Vector2.new(0, -1), -- look towards the island centre
		StarterChest = Vector2.new(-9, 28),
		IslandSign = Vector2.new(9, 31),
		MarketStall = Vector2.new(30, 32),
		FishingSpot = Vector2.new(12, 104), -- on the end of the dock
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
			Vector2.new(-38, -22),
		},
		-- Gatherable starter nodes (ResourceService).
		Nodes = {
			{ Type = "Tree", Position = Vector2.new(-45, 5) },
			{ Type = "Tree", Position = Vector2.new(-50, -12) },
			{ Type = "Tree", Position = Vector2.new(-33, -35) },
			{ Type = "Tree", Position = Vector2.new(38, -30) },
			{ Type = "Tree", Position = Vector2.new(52, -15) },
			{ Type = "Tree", Position = Vector2.new(-20, -56) },
			{ Type = "Rock", Position = Vector2.new(-8, -24) },
			{ Type = "Rock", Position = Vector2.new(12, -22) },
			{ Type = "Rock", Position = Vector2.new(-40, 38) },
			{ Type = "Rock", Position = Vector2.new(45, 45) },
			{ Type = "FiberBush", Position = Vector2.new(-28, 18) },
			{ Type = "FiberBush", Position = Vector2.new(22, 14) },
			{ Type = "FiberBush", Position = Vector2.new(2, -12) },
		},
	},
}

return TableUtil.DeepFreeze(IslandConfig)
