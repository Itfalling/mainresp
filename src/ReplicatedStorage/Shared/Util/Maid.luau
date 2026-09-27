--!strict
--[[
	SCRIPT NAME:  Maid
	SCRIPT TYPE:  ModuleScript (shared utility)
	WHERE:        ReplicatedStorage/Shared/Util/Maid
	DEPENDENCIES: none

	Collects connections / instances / cleanup functions and releases them
	together. Used anywhere a system owns resources tied to a lifetime
	(a character, an island, an open UI panel...).
]]

export type Maid = {
	Give: <T>(self: Maid, task: T) -> T,
	Cleanup: (self: Maid) -> (),
	Destroy: (self: Maid) -> (),
}

local Maid = {}
Maid.__index = Maid

function Maid.new(): Maid
	return (setmetatable({ _tasks = {} }, Maid) :: any) :: Maid
end

function Maid.Give(self: any, item: any): any
	table.insert(self._tasks, item)
	return item
end

local function cleanupTask(item: any)
	local kind = typeof(item)
	if kind == "RBXScriptConnection" then
		item:Disconnect()
	elseif kind == "Instance" then
		item:Destroy()
	elseif kind == "function" then
		item()
	elseif kind == "thread" then
		if coroutine.status(item) == "suspended" then
			task.cancel(item)
		end
	elseif kind == "table" then
		if type(item.Destroy) == "function" then
			item:Destroy()
		elseif type(item.Disconnect) == "function" then
			item:Disconnect()
		end
	end
end

function Maid.Cleanup(self: any)
	local tasks = self._tasks
	self._tasks = {}
	-- Clean up in reverse order of registration (LIFO), like a stack.
	for i = #tasks, 1, -1 do
		local ok, err = pcall(cleanupTask :: any, tasks[i])
		if not ok then
			warn("[Maid] cleanup error:", err)
		end
	end
end

Maid.Destroy = Maid.Cleanup

return Maid
