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

	Every service boots in isolation: if one fails, the error is logged with a
	traceback, published to ReplicatedStorage's "ServerBootErrors" attribute
	(the client shows it on screen), and the remaining services still start.

	SERVICE LAYERS (a service may only require services ABOVE it in this list,
	which keeps require() free of cycles):
		DataService, AntiExploitService, WorldService, SoundService, VFXService, AnimationService
		EconomyService, InventoryService, ProgressionService
		InteractionService, ToolService
		IslandService
		ResourceService, GatherService, BuildService, CropService, FarmService,
		FishingService, AnimalService, ShopService, NPCService, QuestService
		VisitService, TradeService
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
	"ResourceService",
	"GatherService",
	"BuildService",
	"CropService",
	"FarmService",
	"FishingService",
	"AnimalService",
	"ShopService",
	"NPCService",
	"QuestService",
	"VisitService",
	"TradeService",
	"PlayerService",
	"AdminService",
}

local bootErrors: { string } = {}

local function report(label: string, err: any)
	local message = ("%s failed: %s"):format(label, tostring(err))
	warn("[Build Your Island] " .. message)
	table.insert(bootErrors, message)
	ReplicatedStorage:SetAttribute("ServerBootErrors", table.concat(bootErrors, "\n"))
end

Net.Init()

local loaded = {}
for _, name in SERVICE_ORDER do
	local module = Services:FindFirstChild(name)
	if module and module:IsA("ModuleScript") then
		local ok, result = pcall(require, module)
		if ok then
			loaded[name] = result :: any
		else
			report(name .. " (require)", result)
		end
	else
		report(name, "module is missing from ServerScriptService/Server/Services")
	end
end

for _, phase in { "Init", "Start" } do
	for _, name in SERVICE_ORDER do
		local service = loaded[name]
		if service and type(service[phase]) == "function" then
			local ok, err = xpcall(service[phase], debug.traceback)
			if not ok then
				report(name .. "." .. phase, err)
			end
		end
	end
end

Net.FinalizeHandlers()

if #bootErrors == 0 then
	print("[Build Your Island] Server ready —", #SERVICE_ORDER, "services started")
else
	warn(("[Build Your Island] Server started with %d error(s) — see messages above"):format(#bootErrors))
end
