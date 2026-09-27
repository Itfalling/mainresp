--[[
	SCRIPT NAME:  ClientState
	SCRIPT TYPE:  ModuleScript (client)
	WHERE:        StarterPlayerScripts/Client/ClientState
	DEPENDENCIES: Shared.Net, Shared.Util.Signal

	READ-ONLY mirror of the local player's profile, fed by the server's
	StateSync remote (one full snapshot, then batched path updates). The
	client never writes here except by applying server packets — to change
	anything the client sends a request and waits for the server's update.

	Usage:
		ClientState.Observe("Coins", function(coins) ... end) -- fires now (if ready) + on every change
		ClientState.Get("Island", "Level")
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Net"))
local Signal = require(Shared:WaitForChild("Util"):WaitForChild("Signal"))

local ClientState = {}

ClientState.Ready = Signal.new() -- fires once, when the first full snapshot arrives
ClientState.Changed = Signal.new() -- (topLevelKey, path)

local data: { [string]: any }? = nil
local observers: { [string]: any } = {}

local function getSignal(key: string)
	local signal = observers[key]
	if not signal then
		signal = Signal.new()
		observers[key] = signal
	end
	return signal
end

local function notify(key: string, path: { string }?)
	local signal = observers[key]
	if signal and data then
		signal:Fire(data[key], path)
	end
	ClientState.Changed:Fire(key, path)
end

local function applyOp(op: { Path: { string }, Value: any })
	if not data or type(op.Path) ~= "table" or #op.Path == 0 then
		return
	end
	local node = data
	for index = 1, #op.Path - 1 do
		local key = op.Path[index]
		if type(node[key]) ~= "table" then
			node[key] = {}
		end
		node = node[key]
	end
	node[op.Path[#op.Path]] = op.Value
end

function ClientState.IsReady(): boolean
	return data ~= nil
end

function ClientState.WaitForReady()
	if not data then
		ClientState.Ready:Wait()
	end
end

-- ClientState.Get("Inventory", "Items", "Wood")
function ClientState.Get(...: string): any
	local node: any = data
	for _, key in { ... } do
		if type(node) ~= "table" then
			return nil
		end
		node = node[key]
	end
	return node
end

-- Calls callback(value) immediately if ready, then after every change to data[key].
function ClientState.Observe(key: string, callback: (value: any, path: { string }?) -> ())
	local connection = getSignal(key):Connect(callback)
	if data then
		task.spawn(callback, data[key], nil)
	end
	return connection
end

function ClientState.Init()
	Net.OnClientEvent("StateSync", function(packet: any)
		if type(packet) ~= "table" then
			return
		end
		if type(packet.Full) == "table" then
			local firstSnapshot = data == nil
			data = packet.Full
			for key in packet.Full do
				notify(key, nil)
			end
			if firstSnapshot then
				ClientState.Ready:Fire()
			end
		elseif type(packet.Ops) == "table" and data then
			-- Apply every op first, then notify each touched key once.
			local touched: { [string]: { string } } = {}
			for _, op in packet.Ops do
				applyOp(op)
				if type(op.Path) == "table" and op.Path[1] then
					touched[op.Path[1]] = op.Path
				end
			end
			for key, path in touched do
				notify(key, path)
			end
		end
	end)
end

function ClientState.Start()
	Net.FireServer("ClientReady")
end

return ClientState
