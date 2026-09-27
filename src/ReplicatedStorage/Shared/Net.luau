--[[
	SCRIPT NAME:  Net
	SCRIPT TYPE:  ModuleScript (shared networking layer)
	WHERE:        ReplicatedStorage/Shared/Net
	DEPENDENCIES: Shared.Config.RemoteConfig, Shared.Util.RateLimiter
	REQUIRED OBJECTS: none (the server creates ReplicatedStorage/Remotes)

	The only module allowed to touch RemoteEvents.
	  * Server: Net.Init() creates every remote listed in RemoteConfig.
	  * Unknown remote names error immediately (no random remote creation).
	  * Every client->server handler is automatically rate limited and wrapped
	    in pcall; violations are reported to AntiExploitService.
	  * After all services start, Net.FinalizeHandlers() drains remotes that no
	    phase handles yet, flagging clients that fire them.

	Server API:  Net.Init(), Net.OnServerEvent(name, fn(player, ...)),
	             Net.FireClient(name, player, ...), Net.FireAllClients(name, ...),
	             Net.FireClients(name, players, ...), Net.SetViolationHandler(fn),
	             Net.FinalizeHandlers()
	Client API:  Net.FireServer(name, ...), Net.OnClientEvent(name, fn(...))
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RemoteConfig = require(script.Parent.Config.RemoteConfig)
local RateLimiter = require(script.Parent.Util.RateLimiter)

local IS_SERVER = RunService:IsServer()
local FOLDER_NAME = "Remotes"
local CLIENT_WAIT_TIMEOUT = 60

type ViolationHandler = (player: Player, reason: string, weight: number) -> ()

local Net = {}

local folder: Folder? = nil
local remotes: { [string]: RemoteEvent } = {}
local handledOnServer: { [string]: boolean } = {}
local violationHandler: ViolationHandler? = nil

local function reportViolation(player: Player, reason: string, weight: number)
	if violationHandler then
		violationHandler(player, reason, weight)
	end
end

local function getRemote(name: string): RemoteEvent
	local cached = remotes[name]
	if cached then
		return cached
	end
	assert(RemoteConfig.Known[name], ("[Net] Unknown remote '%s' — add it to RemoteConfig"):format(tostring(name)))

	if IS_SERVER then
		assert(folder, "[Net] Net.Init() must run on the server before remotes are used")
		local remote = folder:FindFirstChild(name)
		assert(remote and remote:IsA("RemoteEvent"), "[Net] Remote missing: " .. name)
		remotes[name] = remote
		return remote
	end

	if not folder then
		local found = ReplicatedStorage:WaitForChild(FOLDER_NAME, CLIENT_WAIT_TIMEOUT)
		assert(found and found:IsA("Folder"), "[Net] ReplicatedStorage.Remotes never appeared (is the server running?)")
		folder = found
	end
	assert(folder)
	local remote = folder:WaitForChild(name, CLIENT_WAIT_TIMEOUT)
	assert(remote and remote:IsA("RemoteEvent"), "[Net] Remote missing on client: " .. name)
	remotes[name] = remote
	return remote
end

-- SERVER -------------------------------------------------------------------

function Net.Init()
	assert(IS_SERVER, "Net.Init is server-only")
	if folder then
		return
	end
	local existing = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
	if existing then
		warn("[Net] Replacing an existing ReplicatedStorage.Remotes folder")
		existing:Destroy()
	end
	local newFolder = Instance.new("Folder")
	newFolder.Name = FOLDER_NAME
	for name in RemoteConfig.Known do
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = newFolder
	end
	newFolder.Parent = ReplicatedStorage
	folder = newFolder
end

function Net.SetViolationHandler(handler: ViolationHandler)
	violationHandler = handler
end

function Net.OnServerEvent(name: string, handler: (player: Player, ...any) -> ())
	assert(IS_SERVER, "OnServerEvent is server-only")
	assert(RemoteConfig.Known[name] == "ClientToServer", ("[Net] %s is not a client->server remote"):format(name))
	assert(not handledOnServer[name], ("[Net] %s already has a server handler (one owner per remote)"):format(name))
	handledOnServer[name] = true

	local limits = RemoteConfig.RateLimits[name] or RemoteConfig.DefaultRateLimit
	local limiter = RateLimiter.new(limits.Rate, limits.Burst)

	getRemote(name).OnServerEvent:Connect(function(player: Player, ...)
		if not limiter:Check(player) then
			reportViolation(player, "RateLimit:" .. name, 1)
			return
		end
		local ok, err = pcall(handler, player, ...)
		if not ok then
			warn(("[Net] %s handler error for %s: %s"):format(name, player.Name, tostring(err)))
		end
	end)
end

-- Any client->server remote nobody handles yet (future phases) is drained so
-- the engine queue never fills, and firing it is treated as suspicious.
function Net.FinalizeHandlers()
	assert(IS_SERVER, "FinalizeHandlers is server-only")
	for _, name in RemoteConfig.ClientToServer do
		if not handledOnServer[name] then
			handledOnServer[name] = true
			getRemote(name).OnServerEvent:Connect(function(player: Player)
				reportViolation(player, "UnhandledRemote:" .. name, 2)
			end)
		end
	end
end

function Net.FireClient(name: string, player: Player, ...: any)
	assert(IS_SERVER, "FireClient is server-only")
	assert(RemoteConfig.Known[name] == "ServerToClient", ("[Net] %s is not a server->client remote"):format(name))
	if player.Parent then
		getRemote(name):FireClient(player, ...)
	end
end

function Net.FireClients(name: string, players: { Player }, ...: any)
	for _, player in players do
		Net.FireClient(name, player, ...)
	end
end

function Net.FireAllClients(name: string, ...: any)
	assert(IS_SERVER, "FireAllClients is server-only")
	assert(RemoteConfig.Known[name] == "ServerToClient", ("[Net] %s is not a server->client remote"):format(name))
	getRemote(name):FireAllClients(...)
end

-- CLIENT -------------------------------------------------------------------

function Net.FireServer(name: string, ...: any)
	assert(not IS_SERVER, "FireServer is client-only")
	assert(RemoteConfig.Known[name] == "ClientToServer", ("[Net] %s is not a client->server remote"):format(name))
	getRemote(name):FireServer(...)
end

function Net.OnClientEvent(name: string, handler: (...any) -> ()): RBXScriptConnection
	assert(not IS_SERVER, "OnClientEvent is client-only")
	assert(RemoteConfig.Known[name] == "ServerToClient", ("[Net] %s is not a server->client remote"):format(name))
	return getRemote(name).OnClientEvent:Connect(handler)
end

return Net
