--[[
	SCRIPT NAME:  GameConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/GameConfig
	DEPENDENCIES: Shared.Util.TableUtil

	Global game settings. Anything a designer might want to tune lives in a
	Config module — never hard-code these values inside services/controllers.
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local GameConfig = {
	GameName = "Build Your Island",
	Version = "0.2.0 (First Playable Loop)",

	-- Turn OFF before publishing. Enables verbose logs + /debug output.
	Debug = true,

	StartingCoins = 100,
	StartingGems = 0,
	StartingIslandLevel = 1,
	AutosaveInterval = 60, -- seconds between autosave sweeps (only dirty profiles are written)
	BuildGridSize = 2, -- used by BuildService (Phase 3)
	MaxIslandsPerServer = 8, -- keep >= Players.MaxPlayers in Game Settings

	Character = {
		RequireR15 = true,
		-- If a non-R15 character spawns (Game Settings not set to R15), rebuild it
		-- as R15 from the player's HumanoidDescription. Game Settings > Avatar >
		-- R15 is still the recommended primary setup.
		ForceR15 = true,
		RespawnDelay = 3,
		WalkSpeed = 16,
		JumpHeight = 7.2,
	},

	Camera = {
		MinZoom = 6,
		MaxZoom = 70,
		DefaultFieldOfView = 70,
		MaxShakeIntensity = 1.2, -- hard cap so shakes never become unpleasant
	},

	Inventory = {
		StartingCapacity = 200, -- total resource units the backpack holds
		MaxStack = 9999,
	},

	Data = {
		StoreName = "BuildYourIsland_PlayerData_v1",
		KeyPrefix = "Player_",
		-- "Auto": use the real DataStore, but fall back to an in-memory mock in
		-- Studio when API access is disabled. true = always mock. false = never.
		UseMockDataStore = "Auto",
		LoadAttempts = 5,
		SaveAttempts = 4,
		RetryBaseDelay = 1, -- exponential backoff base (seconds)
		SessionLockTimeout = 1800, -- a lock older than this is considered dead
		LockRetryDelay = 6,
		LockRetries = 5, -- after this many waits the lock is taken over
		StudioStealLocks = true, -- Studio sessions are single-player; don't wait on stale locks
		KickOnLoadFailure = true,
		ShutdownSaveTimeout = 25,
		SizeWarningBytes = 3_500_000,
	},

	AntiExploit = {
		StrikeWindow = 60, -- seconds strikes are remembered for
		WarnStrikes = 10,
		KickStrikes = 40,
		KickEnabled = true,
		MovementCheckInterval = 1,
		MaxSpeedMultiplier = 1.75, -- x WalkSpeed before a movement strike
		MovementSlack = 12, -- studs/sec extra allowance (knockback, slopes, lag)
		TeleportGrace = 3, -- seconds after a server teleport that movement is not checked
		LargeCurrencyGain = 1_000_000, -- single gains above this are logged for review
	},

	-- UserIds allowed to run admin chat commands (see AdminService).
	AdminUserIds = {} :: { number },
	AdminsInStudio = true,

	-- What the Starter Chest on every new island contains.
	StarterKit = {
		Coins = 50,
		Items = { Wood = 10, Stone = 5, Fiber = 5, WheatSeeds = 6 },
		Tools = { "WoodenAxe", "WoodenPickaxe", "WoodenHammer", "WoodenHoe", "WoodenWateringCan", "WoodenFishingRod" },
	},

	-- Lighting / world presentation (WorldService applies these).
	World = {
		ClockTime = 9.5, -- start of the day cycle
		-- A full day takes DayMinutes of real time; nights pass NightSpeed x faster.
		DayCycle = true,
		DayMinutes = 18,
		NightSpeed = 4,
		Brightness = 2.6,
		Ambient = Color3.fromRGB(96, 104, 124),
		OutdoorAmbient = Color3.fromRGB(150, 156, 176),
		NightOutdoorAmbient = Color3.fromRGB(96, 110, 150), -- nights stay readable
		EnvironmentDiffuseScale = 1,
		EnvironmentSpecularScale = 1,
		ShadowSoftness = 0.25,
		Atmosphere = {
			Density = 0.3,
			Offset = 0.12,
			Color = Color3.fromRGB(205, 228, 255),
			Decay = Color3.fromRGB(110, 150, 205),
			Glare = 0.35,
			Haze = 1.1,
		},
		Clouds = { Cover = 0.55, Density = 0.62, Color = Color3.fromRGB(255, 255, 255) },
		SunRays = { Intensity = 0.06, Spread = 0.8 },
		Bloom = { Intensity = 0.45, Size = 22, Threshold = 1.5 },
		ColorCorrection = { Saturation = 0.18, Contrast = 0.08, Brightness = 0.02, TintColor = Color3.fromRGB(255, 250, 244) },
		WaterColor = Color3.fromRGB(26, 176, 196),
		WaterTransparency = 0.78, -- clear enough to see the sandy shallows
		WaterReflectance = 0.3,
		WaterWaveSize = 0.14,
		WaterWaveSpeed = 9,
		-- Terrain material colours (every island theme + every paint material).
		MaterialColors = {
			Grass = Color3.fromRGB(104, 190, 70),
			LeafyGrass = Color3.fromRGB(214, 138, 56), -- autumn ground
			Sand = Color3.fromRGB(242, 224, 166),
			Sandstone = Color3.fromRGB(222, 160, 98),
			Rock = Color3.fromRGB(132, 128, 122),
			Slate = Color3.fromRGB(104, 106, 114),
			Ground = Color3.fromRGB(150, 110, 70),
			Mud = Color3.fromRGB(104, 76, 52),
			Snow = Color3.fromRGB(244, 250, 255),
			Salt = Color3.fromRGB(228, 234, 240),
			Cobblestone = Color3.fromRGB(156, 152, 146),
			Brick = Color3.fromRGB(184, 94, 72),
			WoodPlanks = Color3.fromRGB(176, 124, 76),
			Pavement = Color3.fromRGB(150, 150, 156),
			Limestone = Color3.fromRGB(232, 226, 204),
		},
		OceanDepth = 18,
		SeabedThickness = 8,
		OceanMargin = 600,
		OceanTileSize = 512,
	},
}

return TableUtil.DeepFreeze(GameConfig)
