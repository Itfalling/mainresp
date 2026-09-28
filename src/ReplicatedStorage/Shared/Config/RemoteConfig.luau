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
		"EquipToolRequest", -- (id: string?) a tool OR a holdable item from the hotbar; nil/"" = empty hands
		"HotbarRequest", -- { Op = "Set", Slot, Id } rearrange / put an item on the hotbar
		"InteractRequest", -- (target: Instance) clicked a tree, tile, animal, stall... with what you're holding
		"SwingRequest", -- cosmetic swing at nothing (others see the animation)
		"EmoteRequest", -- ("Wave" | "Cheer" | "Point" | "Dance")
		"CreateIslandRequest", -- { Theme, Shape, Seed, Name } from the Island Creator
		"ExpandIslandRequest", -- (cx, cz) buy a chunk of land
		"PaintTerrainRequest", -- (cells, material)
		"RenameIslandRequest", -- (name)
		"IslandSettingsRequest", -- { Visitors? } | { Helper = userId, Allowed }
		"RemoveNodeRequest", -- (nodeId) clear a natural tree/rock from your island for good
		"BuildRequest", -- { Op = "Place", BuildingId, X, Z, Rotation }
		"DeleteBuildRequest",
		"MoveBuildRequest",
		"FishingRequest", -- { Op = "Cast", Target } | Hook | Reel | Cancel
		"SellItemRequest",
		"PurchaseRequest",
		"VisitRequest", -- (userId) or 0 = go home
		"LikeRequest", -- (ownerUserId)
		"TradeRequest", -- { Op = Invite | Respond | Offer | Coins | Ready | Confirm | Cancel, ... }
		"SettingsRequest", -- { Music, Sfx, CameraShake }
		"CraftRequest", -- reserved (production phase)
	},

	-- Server -> Client pushes (RemoteEvent).
	ServerToClient = {
		"StateSync", -- replicated profile data (full snapshot, then batched path ops)
		"Notify", -- toast / banner / reward popup
		"PlaySound", -- positional or 2D sound from SoundConfig
		"PlayVFX", -- effect from VFXConfig
		"CameraShake", -- small, capped camera shake
		"OpenUI", -- server asks the client to open a screen (Market, IslandSettings, IslandInfo...)
		"FishingEvent", -- cast / bite / reel / result updates for the fishing minigame
		"TradeEvent", -- trade invites and live trade state
	},

	DefaultRateLimit = { Rate = 5, Burst = 10 },

	RateLimits = {
		ClientReady = { Rate = 0.2, Burst = 3 },
		EquipToolRequest = { Rate = 6, Burst = 10 },
		HotbarRequest = { Rate = 4, Burst = 8 },
		InteractRequest = { Rate = 6, Burst = 10 },
		SwingRequest = { Rate = 4, Burst = 6 },
		EmoteRequest = { Rate = 1, Burst = 3 },
		CreateIslandRequest = { Rate = 0.5, Burst = 2 },
		ExpandIslandRequest = { Rate = 1, Burst = 3 },
		PaintTerrainRequest = { Rate = 8, Burst = 16 },
		RenameIslandRequest = { Rate = 0.2, Burst = 2 },
		IslandSettingsRequest = { Rate = 1, Burst = 4 },
		RemoveNodeRequest = { Rate = 2, Burst = 4 },
		BuildRequest = { Rate = 4, Burst = 6 },
		DeleteBuildRequest = { Rate = 2, Burst = 4 },
		MoveBuildRequest = { Rate = 2, Burst = 4 },
		FishingRequest = { Rate = 4, Burst = 8 },
		SellItemRequest = { Rate = 3, Burst = 6 },
		PurchaseRequest = { Rate = 2, Burst = 4 },
		VisitRequest = { Rate = 0.5, Burst = 2 },
		LikeRequest = { Rate = 0.5, Burst = 2 },
		TradeRequest = { Rate = 5, Burst = 12 },
		SettingsRequest = { Rate = 2, Burst = 5 },
		CraftRequest = { Rate = 3, Burst = 6 },
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
