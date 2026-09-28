--!strict
--[[
	SCRIPT NAME:  AssetId
	SCRIPT TYPE:  ModuleScript (shared utility)
	WHERE:        ReplicatedStorage/Shared/Util/AssetId
	DEPENDENCIES: none

	Some asset slots have no verified asset yet and use the literal
	"rbxassetid://PLACEHOLDER". Systems call AssetId.IsPlaceholder() and
	skip / fall back instead of erroring. Built-in "rbxasset://" paths and
	real "rbxassetid://<number>" ids are never placeholders.
]]

local AssetId = {}

AssetId.PLACEHOLDER = "rbxassetid://PLACEHOLDER"

function AssetId.IsPlaceholder(id: string?): boolean
	if id == nil or id == "" then
		return true
	end
	if string.find(id, "PLACEHOLDER", 1, true) then
		return true
	end
	return id == "rbxassetid://0"
end

return AssetId
