--!strict
--[[
	SCRIPT NAME:  CropGrowth
	SCRIPT TYPE:  ModuleScript (shared utility)
	WHERE:        ReplicatedStorage/Shared/Util/CropGrowth
	DEPENDENCIES: Shared.Config.CropConfig

	Pure crop growth math from timestamps. Used by the server (authoritative
	stages, offline growth) and the client (countdown labels) so both agree.

	A planted tile entry looks like:
		{ CropId = "Wheat", PlantedAt = <unix>, WateredAt = <unix or 0> }
]]

local CropConfig = require(script.Parent.Parent.Config.CropConfig)

local CropGrowth = {}

export type Entry = { CropId: string?, PlantedAt: number?, WateredAt: number? }

-- 0..1 growth progress.
function CropGrowth.GetProgress(entry: Entry, now: number): number
	local crop = entry.CropId and CropConfig.Crops[entry.CropId]
	local planted = entry.PlantedAt
	if not crop or type(planted) ~= "number" then
		return 0
	end
	local watered = entry.WateredAt or 0
	local multiplier = CropConfig.WaterSpeedMultiplier
	local effective: number
	if watered > 0 and watered >= planted then
		effective = math.min(watered, now) - planted + math.max(0, now - watered) * multiplier
	else
		effective = now - planted
	end
	return math.clamp(effective / crop.GrowTime, 0, 1)
end

-- 1..6 (6 = Harvestable). Stage names are CropConfig.Stages.
function CropGrowth.GetStage(entry: Entry, now: number): number
	local progress = CropGrowth.GetProgress(entry, now)
	if progress >= 1 then
		return #CropConfig.Stages
	end
	return math.clamp(math.floor(progress * (#CropConfig.Stages - 1)) + 1, 1, #CropConfig.Stages - 1)
end

-- Seconds until harvestable at the current growth speed.
function CropGrowth.GetRemaining(entry: Entry, now: number): number
	local crop = entry.CropId and CropConfig.Crops[entry.CropId]
	if not crop then
		return 0
	end
	local progress = CropGrowth.GetProgress(entry, now)
	local rate = if (entry.WateredAt or 0) > 0 then CropConfig.WaterSpeedMultiplier else 1
	return math.max(0, crop.GrowTime * (1 - progress) / rate)
end

function CropGrowth.IsWatered(entry: Entry): boolean
	return (entry.WateredAt or 0) > 0
end

return CropGrowth
