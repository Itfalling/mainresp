--[[
	SCRIPT NAME:  IslandConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/IslandConfig
	DEPENDENCIES: Shared.Util.TableUtil

	Every island is UNIQUE. An island is a set of land CHUNKS (ChunkSize x
	ChunkSize studs) on a grid around the island centre, plus a Seed, a
	THEME (biome look, trees, fish) and a SHAPE (how the starter land is laid
	out). Shared/Util/IslandGen turns that into an organic coastline, beaches,
	hills and resource spots — deterministically, so the same saved island
	always rebuilds identically on any server.

	Players EXPAND by buying any water chunk that touches their land, in any
	direction, so no two islands grow the same way. They customise further by
	painting terrain, planting trees, placing rocks/flowers, moving the market
	stall and naming the island.

	COORDINATES: island-local. (0, 0) is the island centre at sea level.
	Chunk (cx, cz) covers X in [cx*C - C/2, cx*C + C/2] (C = ChunkSize).
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local IslandConfig = {
	SeaLevel = 0,

	-- Server slot grid. Islands are SlotSpacing studs apart so they never touch.
	SlotSpacing = 1000,
	SlotsPerRow = 4,

	ChunkSize = 16,
	GridRadius = 13, -- chunks may go from -GridRadius..GridRadius on each axis
	StarterChunks = 52,
	-- Always-land plaza around the centre (chunk offsets), so spawn + landmarks fit.
	PlazaRadius = 2.3, -- in chunks (euclidean)
	FlattenRadius = 30, -- studs around the centre kept flat for building

	LandHeight = 3, -- inland ground height above sea level
	BeachWidth = 8, -- studs of sloping beach
	CoastNoise = 5, -- studs the coastline wobbles
	BuildCoastDistance = 4, -- buildings must be this far inland (studs, after noise)

	Expansion = {
		-- Price of the next chunk: BaseCost + Linear*n + Quadratic*n^2 (n = chunks bought so far)
		BaseCost = 100,
		Linear = 10,
		Quadratic = 0.2,
		ChunksPerIslandLevel = 12, -- max land = StarterChunks + (level-1) * this
		MaxChunks = 600,
	},

	DefaultNameFormat = "%s's Island",
	NameMaxLength = 24,
	DefaultTheme = "Tropical",
	DefaultShape = "Round",

	ThemeOrder = { "Tropical", "Meadow", "Autumn", "Snowy", "Desert" },
	Themes = {
		Tropical = {
			DisplayName = "Tropical",
			Icon = "🌴",
			Description = "Palm trees, white beaches and bright fish.",
			Ground = "Grass",
			Alt = "Grass",
			Beach = "Sand",
			Cliff = "Rock",
			Seabed = "Sand",
			HillAmp = 5,
			Color = Color3.fromRGB(80, 200, 120),
			Nodes = { PalmTree = 5, Tree = 2, Rock = 3, FiberBush = 3, SandPile = 2 },
			Deco = { "Flowers", "Shells", "Tuft" },
			NearFish = "Shore",
		},
		Meadow = {
			DisplayName = "Meadow",
			Icon = "🌳",
			Description = "Rolling green hills and big oak trees.",
			Ground = "Grass",
			Alt = "Grass",
			Beach = "Sand",
			Cliff = "Slate",
			Seabed = "Sand",
			HillAmp = 9,
			Color = Color3.fromRGB(120, 200, 70),
			Nodes = { Tree = 6, Rock = 3, FiberBush = 3, ClayPatch = 1 },
			Deco = { "Flowers", "Flowers", "Tuft" },
			NearFish = "River",
		},
		Autumn = {
			DisplayName = "Autumn",
			Icon = "🍂",
			Description = "Golden leaves, orange trees and cosy vibes.",
			Ground = "LeafyGrass",
			Alt = "Ground",
			Beach = "Sand",
			Cliff = "Slate",
			Seabed = "Sand",
			HillAmp = 10,
			Color = Color3.fromRGB(235, 140, 50),
			Nodes = { AutumnTree = 6, Rock = 3, FiberBush = 2, ClayPatch = 1 },
			Deco = { "Leaves", "Mushrooms", "Tuft" },
			NearFish = "River",
		},
		Snowy = {
			DisplayName = "Snowy",
			Icon = "❄️",
			Description = "Snow-covered pines and icy water full of rare fish.",
			Ground = "Snow",
			Alt = "Snow",
			Beach = "Salt",
			Cliff = "Rock",
			Seabed = "Sand",
			HillAmp = 12,
			Color = Color3.fromRGB(170, 220, 255),
			Nodes = { SnowPine = 6, Rock = 4, IronRock = 1 },
			Deco = { "Snowball", "Pebbles" },
			NearFish = "Cave",
		},
		Desert = {
			DisplayName = "Desert",
			Icon = "🌵",
			Description = "Warm dunes, cacti and hidden clay.",
			Ground = "Sandstone",
			Alt = "Sand",
			Beach = "Sand",
			Cliff = "Sandstone",
			Seabed = "Sand",
			HillAmp = 6,
			Color = Color3.fromRGB(240, 190, 100),
			Nodes = { Cactus = 4, PalmTree = 2, Rock = 3, SandPile = 3, ClayPatch = 2 },
			Deco = { "Pebbles", "DryTuft" },
			NearFish = "Shore",
		},
	},

	ShapeOrder = { "Round", "Crescent", "Twin", "Long", "Wild" },
	Shapes = {
		Round = { DisplayName = "Round", Icon = "⚪", Description = "A classic round island." },
		Crescent = { DisplayName = "Crescent", Icon = "🌙", Description = "Curves around a sheltered bay." },
		Twin = { DisplayName = "Twin Isles", Icon = "♾️", Description = "Two lobes joined in the middle." },
		Long = { DisplayName = "Longshore", Icon = "➖", Description = "A long island with endless beaches." },
		Wild = { DisplayName = "Wild", Icon = "🌀", Description = "Jagged, unpredictable coastline." },
	},

	-- Island-local positions of the starter landmarks (inside the plaza).
	StarterLayout = {
		Spawn = Vector2.new(0, 12),
		SpawnFacing = Vector2.new(0, -1),
		StarterChest = Vector2.new(-9, 4),
		IslandSign = Vector2.new(9, 4),
		MarketStall = { Position = Vector2.new(0, -14), Rotation = 180 },
		SoilTiles = {
			Vector2.new(18, -6), Vector2.new(23, -6), Vector2.new(28, -6),
			Vector2.new(18, -1), Vector2.new(23, -1), Vector2.new(28, -1),
		},
		KeepClearRadius = 26, -- no generated resources this close to the centre
	},

	-- Terrain paint palette (build mode → Paint). Name = Enum.Material name.
	PaintOrder = { "Grass", "LeafyGrass", "Snow", "Sand", "Sandstone", "Ground", "Mud", "Cobblestone", "Brick", "WoodPlanks", "Pavement", "Slate", "Limestone" },
	Paint = {
		Grass = { DisplayName = "Grass", Icon = "🟩" },
		LeafyGrass = { DisplayName = "Autumn Grass", Icon = "🟧" },
		Snow = { DisplayName = "Snow", Icon = "⬜" },
		Sand = { DisplayName = "Sand", Icon = "🟨" },
		Sandstone = { DisplayName = "Sandstone", Icon = "🟫" },
		Ground = { DisplayName = "Dirt", Icon = "🟤" },
		Mud = { DisplayName = "Mud", Icon = "🟤" },
		Cobblestone = { DisplayName = "Cobble Path", Icon = "🪨" },
		Brick = { DisplayName = "Brick Path", Icon = "🧱" },
		WoodPlanks = { DisplayName = "Wood Deck", Icon = "🪵" },
		Pavement = { DisplayName = "Stone Tiles", Icon = "⬛" },
		Slate = { DisplayName = "Slate", Icon = "🌑" },
		Limestone = { DisplayName = "Limestone", Icon = "🤍" },
	},
	PaintCellSize = 8,
	MaxPaintCells = 3000,

	-- Visiting (VisitService).
	VisitorModes = { "Everyone", "Friends", "Nobody" },
}

return TableUtil.DeepFreeze(IslandConfig)
