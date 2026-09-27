--!strict
--[[
	SCRIPT NAME:  IslandLayout
	SCRIPT TYPE:  ModuleScript (shared utility)
	WHERE:        ReplicatedStorage/Shared/Util/IslandLayout
	DEPENDENCIES: Shared.Config.IslandConfig

	Pure math for island slots and areas. Shared so the server (validation) and
	client (build preview, UI) always agree on where land is.
]]

local IslandConfig = require(script.Parent.Parent.Config.IslandConfig)

local IslandLayout = {}

-- World-space origin (CFrame at sea level) of server island slot `index` (1-based).
function IslandLayout.GetSlotOrigin(index: number): CFrame
	local zeroBased = index - 1
	local column = zeroBased % IslandConfig.SlotsPerRow
	local row = zeroBased // IslandConfig.SlotsPerRow
	local x = column * IslandConfig.SlotSpacing
	local z = row * IslandConfig.SlotSpacing
	return CFrame.new(x, IslandConfig.SeaLevel, z)
end

-- Island-local XZ centre of an area.
function IslandLayout.GetAreaCenter(areaId: string): Vector2
	local area = IslandConfig.Areas[areaId]
	assert(area, "Unknown area " .. tostring(areaId))
	local angle = math.rad(area.Angle)
	return Vector2.new(math.sin(angle), math.cos(angle)) * area.Distance
end

-- Where the 🔒 unlock sign for an area stands: on the starter shore, facing it.
function IslandLayout.GetAreaMarkerPosition(areaId: string): Vector2
	local area = IslandConfig.Areas[areaId]
	local angle = math.rad(area.Angle)
	local direction = Vector2.new(math.sin(angle), math.cos(angle))
	return direction * (IslandConfig.Areas.Starter.Radius - 8)
end

-- Is an island-local XZ point inside the given area's circle (minus margin)?
function IslandLayout.IsInArea(areaId: string, localPoint: Vector2, margin: number?): boolean
	local area = IslandConfig.Areas[areaId]
	if not area then
		return false
	end
	local center = IslandLayout.GetAreaCenter(areaId)
	return (localPoint - center).Magnitude <= area.Radius - (margin or 0)
end

-- Is the point on land the owner has unlocked?
function IslandLayout.IsOnUnlockedLand(unlockedAreas: { [string]: boolean }, localPoint: Vector2, margin: number?): boolean
	for areaId, unlocked in unlockedAreas do
		if unlocked and IslandLayout.IsInArea(areaId, localPoint, margin) then
			return true
		end
	end
	return false
end

-- Largest distance from island centre any area can reach (used for cleanup bounds).
function IslandLayout.GetMaxExtent(): number
	local extent = 0
	for _, area: any in IslandConfig.Areas do
		extent = math.max(extent, area.Distance + area.Radius + IslandConfig.ShallowsWidth)
	end
	return extent
end

return IslandLayout
