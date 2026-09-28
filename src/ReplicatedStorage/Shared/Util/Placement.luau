--!strict
--[[
	SCRIPT NAME:  Placement
	SCRIPT TYPE:  ModuleScript (shared utility)
	WHERE:        ReplicatedStorage/Shared/Util/Placement
	DEPENDENCIES: Shared.Config.{BuildConfig, BuildingConfig}, Shared.Util.IslandLayout

	Build-grid math shared by the client preview and the server validator.
	All positions are ISLAND-LOCAL.
]]

local Config = script.Parent.Parent.Config
local BuildConfig = require(Config.BuildConfig)
local IslandLayout = require(script.Parent.IslandLayout)

local Placement = {}

function Placement.IsValidRotation(rotation: any): boolean
	return type(rotation) == "number" and table.find(BuildConfig.Rotations, rotation) ~= nil
end

-- Footprint (X, Z) after rotation.
function Placement.FootprintSize(footprint: Vector2, rotation: number): Vector2
	if rotation == 90 or rotation == 270 then
		return Vector2.new(footprint.Y, footprint.X)
	end
	return footprint
end

local function snapAxis(value: number, span: number): number
	local grid = BuildConfig.GridSize
	local cells = math.floor(span / grid + 0.5)
	if cells % 2 == 1 then
		-- Odd number of cells: centre sits in the middle of a cell.
		return math.floor(value / grid) * grid + grid / 2
	end
	return math.floor(value / grid + 0.5) * grid
end

-- Snaps an island-local XZ centre so the footprint's edges land on grid lines.
function Placement.Snap(localXZ: Vector2, size: Vector2): Vector2
	return Vector2.new(snapAxis(localXZ.X, size.X), snapAxis(localXZ.Y, size.Y))
end

function Placement.Corners(center: Vector2, size: Vector2): { Vector2 }
	local hx, hz = size.X / 2, size.Y / 2
	return {
		center + Vector2.new(-hx, -hz),
		center + Vector2.new(hx, -hz),
		center + Vector2.new(-hx, hz),
		center + Vector2.new(hx, hz),
	}
end

-- Every corner (and the centre) must be on land the owner has unlocked.
function Placement.IsOnUnlockedLand(unlocked: { [string]: boolean }, center: Vector2, size: Vector2): boolean
	if not IslandLayout.IsOnUnlockedLand(unlocked, center, BuildConfig.EdgeMargin) then
		return false
	end
	for _, corner in Placement.Corners(center, size) do
		if not IslandLayout.IsOnUnlockedLand(unlocked, corner, BuildConfig.EdgeMargin) then
			return false
		end
	end
	return true
end

-- Island-local CFrame of a building's base centre.
function Placement.LocalCFrame(localPosition: Vector3, rotation: number): CFrame
	return CFrame.new(localPosition) * CFrame.Angles(0, math.rad(rotation), 0)
end

return Placement
