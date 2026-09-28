--[[
	SCRIPT NAME:  RemoteConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/RemoteConfig
	DEPENDENCIES: Shared.Util.TableUtil

	The complete, centralized list of network remotes. Net creates exactly
	these (and nothing else) inside ReplicatedStorage/Remotes when the server
	boots. All names are declared up-front — including ones later phases will
	use — so remote names never change between phases.

	RateLimits: token bucket per player per remote. Rate = tokens/second,
	Burst = bucket size. Requests over the limit are dropped and reported to
	AntiExploitService.
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local RemoteConfig = {
	-- Client -> Server requests (RemoteEvent). The server validates EVERYTHING.
	ClientToServer = {
		"ClientReady", -- client finished loading; server replies with a full StateSync
		"EquipToolRequest", -- (toolId: string?) nil/"" = unequip
		"UnlockAreaRequest", -- (areaId: string)
		"GatherRequest", -- Phase 2
		"BuildRequest", -- Phase 3
		"DeleteBuildRequest", -- Phase 3
		"MoveBuildRequest", -- Phase 3
		"PlantCropRequest", -- Phase 4
		"WaterCropRequest", -- Phase 4
		"HarvestCropRequest", -- Phase 4
		"FishingRequest", -- Phase 5
		"AnimalInteractRequest", -- Phase 6
		"MilkAnimalRequest", -- Phase 6
		"SellItemRequest", -- Phase 7
		"PurchaseRequest", -- Phase 7
		"UpgradeRequest", -- Phase 7
		"CraftRequest", -- Phase 8
		"QuestRequest", -- Phase 10
		"IslandPermissionRequest", -- Phase 12
		"IslandVisitRequest", -- Phase 12
		"SettingsRequest", -- Phase 16
	},

	-- Server -> Client pushes (RemoteEvent).
	ServerToClient = {
		"StateSync", -- replicated profile data (full snapshot, then batched path ops)
		"Notify", -- toast / banner / reward popup
		"PlaySound", -- positional or 2D sound from SoundConfig
		"PlayVFX", -- effect from VFXConfig
		"CameraShake", -- small, capped camera shake
		"AnimationCommand", -- server asks the owning client to play/stop an animation
		"OpenUI", -- server asks the client to open a screen (Market, SeedPicker)
		"FishingEvent", -- cast / bite / reel / result updates for the fishing minigame
	},

	DefaultRateLimit = { Rate = 5, Burst = 10 },

	RateLimits = {
		ClientReady = { Rate = 0.2, Burst = 3 },
		EquipToolRequest = { Rate = 6, Burst = 10 },
		UnlockAreaRequest = { Rate = 1, Burst = 3 },
		GatherRequest = { Rate = 4, Burst = 6 },
		BuildRequest = { Rate = 4, Burst = 6 },
		DeleteBuildRequest = { Rate = 2, Burst = 4 },
		MoveBuildRequest = { Rate = 2, Burst = 4 },
		PlantCropRequest = { Rate = 6, Burst = 12 },
		WaterCropRequest = { Rate = 6, Burst = 12 },
		HarvestCropRequest = { Rate = 6, Burst = 12 },
		FishingRequest = { Rate = 4, Burst = 8 },
		AnimalInteractRequest = { Rate = 3, Burst = 6 },
		MilkAnimalRequest = { Rate = 2, Burst = 4 },
		SellItemRequest = { Rate = 3, Burst = 6 },
		PurchaseRequest = { Rate = 2, Burst = 4 },
		UpgradeRequest = { Rate = 2, Burst = 4 },
		CraftRequest = { Rate = 3, Burst = 6 },
		QuestRequest = { Rate = 2, Burst = 5 },
		IslandPermissionRequest = { Rate = 1, Burst = 3 },
		IslandVisitRequest = { Rate = 0.5, Burst = 2 },
		SettingsRequest = { Rate = 2, Burst = 5 },
	},

	-- Built below: set of every valid remote name -> direction.
	Known = {} :: { [string]: string },
}

for _, name in RemoteConfig.ClientToServer do
	RemoteConfig.Known[name] = "ClientToServer"
end
for _, name in RemoteConfig.ServerToClient do
	assert(RemoteConfig.Known[name] == nil, "Duplicate remote name " .. name)
	RemoteConfig.Known[name] = "ServerToClient"
end

return TableUtil.DeepFreeze(RemoteConfig)
