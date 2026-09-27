--[[
	SCRIPT NAME:  MockDataStore
	SCRIPT TYPE:  ModuleScript (server)
	WHERE:        ServerScriptService/Server/Data/MockDataStore
	DEPENDENCIES: Shared.Util.TableUtil

	In-memory stand-in for a GlobalDataStore, used in Studio when "Enable
	Studio Access to API Services" is off. Same UpdateAsync/GetAsync contract,
	so DataService runs the exact same code path. Data lives only for the
	current play session.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableUtil = require(ReplicatedStorage.Shared.Util.TableUtil)

local MockDataStore = {}
MockDataStore.__index = MockDataStore

function MockDataStore.new()
	return setmetatable({ _data = {} :: { [string]: any } }, MockDataStore)
end

function MockDataStore:GetAsync(key: string): any
	task.wait() -- simulate yielding like the real API
	return TableUtil.DeepCopy(self._data[key])
end

function MockDataStore:UpdateAsync(key: string, transform: (any, any) -> any): any
	task.wait()
	local result = transform(TableUtil.DeepCopy(self._data[key]), nil)
	if result == nil then
		return nil -- cancelled, mirrors the real API
	end
	self._data[key] = TableUtil.DeepCopy(result)
	return TableUtil.DeepCopy(result)
end

function MockDataStore:RemoveAsync(key: string): any
	local old = self._data[key]
	self._data[key] = nil
	return old
end

return MockDataStore
