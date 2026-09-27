--!strict
--[[
	SCRIPT NAME:  Validate
	SCRIPT TYPE:  ModuleScript (shared utility, used mostly by the server)
	WHERE:        ReplicatedStorage/Shared/Util/Validate
	DEPENDENCIES: none

	Type guards for anything that crosses the network. Every RemoteEvent
	handler validates its arguments with these before touching game state.
	Never trust types coming from a client.
]]

local Validate = {}

function Validate.IsFinite(value: any): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

function Validate.Number(value: any, min: number?, max: number?): boolean
	if not Validate.IsFinite(value) then
		return false
	end
	if min and value < min then
		return false
	end
	if max and value > max then
		return false
	end
	return true
end

function Validate.Integer(value: any, min: number?, max: number?): boolean
	return Validate.Number(value, min, max) and math.floor(value) == value
end

function Validate.String(value: any, maxLength: number?): boolean
	if type(value) ~= "string" then
		return false
	end
	if maxLength and #value > maxLength then
		return false
	end
	return utf8.len(value) ~= nil
end

-- Config identifiers: letters, digits and underscores only.
function Validate.Id(value: any): boolean
	return Validate.String(value, 64) and string.match(value, "^[%w_]+$") ~= nil
end

function Validate.Boolean(value: any): boolean
	return type(value) == "boolean"
end

function Validate.Vector3(value: any, maxMagnitude: number?): boolean
	if typeof(value) ~= "Vector3" then
		return false
	end
	if not (Validate.IsFinite(value.X) and Validate.IsFinite(value.Y) and Validate.IsFinite(value.Z)) then
		return false
	end
	return maxMagnitude == nil or value.Magnitude <= maxMagnitude
end

function Validate.OneOf(value: any, allowed: { [any]: any }): boolean
	return value ~= nil and allowed[value] ~= nil
end

return Validate
