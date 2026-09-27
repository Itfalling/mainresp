--!strict
--[[
	SCRIPT NAME:  Serializer
	SCRIPT TYPE:  ModuleScript (shared utility)
	WHERE:        ReplicatedStorage/Shared/Util/Serializer
	DEPENDENCIES: none

	Converts Roblox datatypes into DataStore-safe tables and back.
	Instances are NEVER saved; only plain data like:
		{ BuildingId = "WoodenCabin", Position = { X = 10, Y = 5, Z = -30 }, Rotation = 90 }
	All island positions are saved in ISLAND-LOCAL space so an island can be
	loaded into any server slot.
]]

export type SerializedVector3 = { X: number, Y: number, Z: number }

local Serializer = {}

local function round(value: number, step: number): number
	return math.floor(value / step + 0.5) * step
end

function Serializer.Vector3(value: Vector3): SerializedVector3
	return { X = round(value.X, 0.01), Y = round(value.Y, 0.01), Z = round(value.Z, 0.01) }
end

function Serializer.ToVector3(data: any): Vector3?
	if type(data) ~= "table" then
		return nil
	end
	local x, y, z = data.X, data.Y, data.Z
	if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then
		return nil
	end
	if x ~= x or y ~= y or z ~= z then
		return nil
	end
	return Vector3.new(x, y, z)
end

-- Rotation is stored as a yaw angle in whole degrees (0..359).
function Serializer.Yaw(cframe: CFrame): number
	local _, yaw, _ = cframe:ToEulerAnglesYXZ()
	return round(math.deg(yaw), 1) % 360
end

function Serializer.ToCFrame(position: Vector3, yawDegrees: number): CFrame
	return CFrame.new(position) * CFrame.Angles(0, math.rad(yawDegrees), 0)
end

return Serializer
