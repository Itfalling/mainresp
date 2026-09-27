--[[
	SCRIPT NAME:  Main
	SCRIPT TYPE:  Script (server entry point)
	WHERE:        ServerScriptService/Server/Main
	DEPENDENCIES: every module in ServerScriptService/Server/Services, Shared.Net

	Boots the server in a deterministic order:
	  1. Net.Init()        create ReplicatedStorage/Remotes from RemoteConfig
	  2. Service.Init()    register handlers/kinds; no cross-service calls that yield
	  3. Service.Start()   connect events, start loops, accept players
	  4. Net.FinalizeHandlers()  drain remotes no phase handles yet

	SERVICE LAYERS (a service may only require services ABOVE it in this list,
	which keeps require() free of cycles):
		DataService, AntiExploitService, WorldService, SoundService, VFXService, AnimationService
		EconomyService, InventoryService, ProgressionService
		InteractionService, ToolService
		IslandService
		PlayerService, AdminService
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)
local Services = script.Parent.Services

local SERVICE_ORDER = {
	"DataService",
	"AntiExploitService",
	"WorldService",
	"SoundService",
	"VFXService",
	"AnimationService",
	"EconomyService",
	"InventoryService",
	"ProgressionService",
	"InteractionService",
	"ToolService",
	"IslandService",
	"PlayerService",
	"AdminService",
}

Net.Init()

local loaded = {}
for _, name in SERVICE_ORDER do
	local module = Services:FindFirstChild(name)
	assert(module and module:IsA("ModuleScript"), "Missing service module: " .. name)
	loaded[name] = require(module) :: any
end

for _, name in SERVICE_ORDER do
	local service = loaded[name]
	if type(service.Init) == "function" then
		service.Init()
	end
end

for _, name in SERVICE_ORDER do
	local service = loaded[name]
	if type(service.Start) == "function" then
		service.Start()
	end
end

Net.FinalizeHandlers()

print("[Build Your Island] Server ready —", #SERVICE_ORDER, "services started")
