--!strict
--[[
	SCRIPT NAME:  AssetId
	SCRIPT TYPE:  ModuleScript (shared utility)
	WHERE:        ReplicatedStorage/Shared/Util/AssetId
	DEPENDENCIES: none

	This project ships WITHOUT real animation / sound asset IDs. Every asset
	slot uses the literal "rbxassetid://PLACEHOLDER". Systems call
	AssetId.IsPlaceholder() and gracefully fall back instead of erroring,
	so the game keeps working until real IDs are pasted into the configs.
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
