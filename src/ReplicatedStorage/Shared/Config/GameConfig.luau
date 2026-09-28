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
		ClockTime = 14.5,
		Brightness = 2.2,
		Ambient = Color3.fromRGB(110, 110, 125),
		OutdoorAmbient = Color3.fromRGB(150, 150, 165),
		EnvironmentDiffuseScale = 1,
		EnvironmentSpecularScale = 1,
		Atmosphere = {
			Density = 0.28,
			Offset = 0.1,
			Color = Color3.fromRGB(199, 225, 255),
			Decay = Color3.fromRGB(120, 160, 200),
			Glare = 0.15,
			Haze = 1.2,
		},
		WaterColor = Color3.fromRGB(40, 170, 200),
		WaterTransparency = 0.6,
		WaterReflectance = 0.25,
		WaterWaveSize = 0.12,
		WaterWaveSpeed = 8,
		MaterialColors = {
			Grass = Color3.fromRGB(106, 190, 72),
			LeafyGrass = Color3.fromRGB(92, 170, 60),
			Sand = Color3.fromRGB(240, 220, 160),
			Rock = Color3.fromRGB(128, 124, 118),
			Ground = Color3.fromRGB(140, 105, 70),
		},
		OceanDepth = 18,
		SeabedThickness = 8,
		OceanMargin = 600,
		OceanTileSize = 512,
	},
}

return TableUtil.DeepFreeze(GameConfig)
