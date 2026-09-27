--!strict
--[[
	SCRIPT NAME:  TableUtil
	SCRIPT TYPE:  ModuleScript (shared utility)
	WHERE:        ReplicatedStorage/Shared/Util/TableUtil
	DEPENDENCIES: none
]]

local TableUtil = {}

function TableUtil.DeepCopy<T>(value: T): T
	if type(value) ~= "table" then
		return value
	end
	local copy = {}
	for key, child in value :: any do
		copy[TableUtil.DeepCopy(key)] = TableUtil.DeepCopy(child)
	end
	return (copy :: any) :: T
end

-- Fills in any keys missing from `target` using a deep copy of `template`.
-- Existing values are left untouched (type repair is DataSchema's job).
function TableUtil.Reconcile(target: { [any]: any }, template: { [any]: any })
	for key, templateValue in template do
		if target[key] == nil then
			target[key] = TableUtil.DeepCopy(templateValue)
		elseif type(templateValue) == "table" and type(target[key]) == "table" then
			TableUtil.Reconcile(target[key], templateValue)
		end
	end
end

function TableUtil.Count(dict: { [any]: any }): number
	local count = 0
	for _ in dict do
		count += 1
	end
	return count
end

function TableUtil.Keys<K>(dict: { [K]: any }): { K }
	local keys = {}
	for key in dict do
		table.insert(keys, key)
	end
	return keys
end

-- Recursively freezes a config table so accidental writes error loudly.
function TableUtil.DeepFreeze<T>(value: T): T
	if type(value) == "table" and not table.isfrozen(value :: any) then
		for _, child in value :: any do
			TableUtil.DeepFreeze(child)
		end
		table.freeze(value :: any)
	end
	return value
end

return TableUtil
