--!strict
--[[
	SCRIPT NAME:  IslandLayout
	SCRIPT TYPE:  ModuleScript (shared utility)
	WHERE:        ReplicatedStorage/Shared/Util/IslandLayout
	DEPENDENCIES: Shared.Config.IslandConfig

	Where each server island SLOT sits in the world. Island shape, land and
	coastlines live in Shared/Util/IslandGen.
]]

local IslandConfig = require(script.Parent.Parent.Config.IslandConfig)

local IslandLayout = {}

-- World-space origin (CFrame at sea level) of server island slot `index` (1-based).
-- Slot spacing is a multiple of 4, so origins sit on the terrain voxel grid.
function IslandLayout.GetSlotOrigin(index: number): CFrame
	local zeroBased = index - 1
	local column = zeroBased % IslandConfig.SlotsPerRow
	local row = zeroBased // IslandConfig.SlotsPerRow
	local x = column * IslandConfig.SlotSpacing
	local z = row * IslandConfig.SlotSpacing
	return CFrame.new(x, IslandConfig.SeaLevel, z)
end

-- Largest distance from an island centre its land can reach.
function IslandLayout.GetMaxExtent(): number
	return (IslandConfig.GridRadius + 1.5) * IslandConfig.ChunkSize
end

return IslandLayout
