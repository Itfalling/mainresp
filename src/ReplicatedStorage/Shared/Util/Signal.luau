--!strict
--[[
	SCRIPT NAME:  Signal
	SCRIPT TYPE:  ModuleScript (shared utility)
	WHERE:        ReplicatedStorage/Shared/Util/Signal
	DEPENDENCIES: none

	Lightweight script signal used by services and controllers for in-process
	events (never for networking — that is Net's job).

	Usage:
		local changed = Signal.new()
		local conn = changed:Connect(function(a, b) end)
		changed:Fire(1, 2)
		conn:Disconnect()
]]

export type Connection = {
	Connected: boolean,
	Disconnect: (self: Connection) -> (),
}

export type Signal = {
	Connect: (self: Signal, fn: (...any) -> ()) -> Connection,
	Once: (self: Signal, fn: (...any) -> ()) -> Connection,
	Fire: (self: Signal, ...any) -> (),
	Wait: (self: Signal) -> ...any,
	DisconnectAll: (self: Signal) -> (),
	Destroy: (self: Signal) -> (),
}

type ConnectionImpl = {
	Connected: boolean,
	_signal: any,
	_fn: (...any) -> (),
	Disconnect: (self: ConnectionImpl) -> (),
}

local Connection = {}
Connection.__index = Connection

function Connection.Disconnect(self: ConnectionImpl)
	if not self.Connected then
		return
	end
	self.Connected = false
	local handlers = self._signal._handlers
	local index = table.find(handlers, self)
	if index then
		table.remove(handlers, index)
	end
end

local Signal = {}
Signal.__index = Signal

function Signal.new(): Signal
	local self = setmetatable({
		_handlers = {} :: { ConnectionImpl },
	}, Signal)
	return (self :: any) :: Signal
end

function Signal.Connect(self: any, fn: (...any) -> ()): Connection
	local connection = setmetatable({
		Connected = true,
		_signal = self,
		_fn = fn,
	}, Connection)
	table.insert(self._handlers, connection)
	return (connection :: any) :: Connection
end

function Signal.Once(self: any, fn: (...any) -> ()): Connection
	local connection: Connection
	connection = Signal.Connect(self, function(...)
		connection:Disconnect()
		fn(...)
	end)
	return connection
end

function Signal.Fire(self: any, ...: any)
	-- Copy so handlers can disconnect while we iterate.
	local snapshot: { ConnectionImpl } = table.clone(self._handlers)
	for _, connection in snapshot do
		if connection.Connected then
			task.spawn(connection._fn, ...)
		end
	end
end

function Signal.Wait(self: any): ...any
	local thread = coroutine.running()
	Signal.Once(self, function(...)
		task.spawn(thread, ...)
	end)
	return coroutine.yield()
end

function Signal.DisconnectAll(self: any)
	for _, connection in self._handlers do
		connection.Connected = false
	end
	table.clear(self._handlers)
end

function Signal.Destroy(self: any)
	Signal.DisconnectAll(self)
end

return Signal
