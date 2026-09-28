--!strict
--[[
	SCRIPT NAME:  AnimalMath
	SCRIPT TYPE:  ModuleScript (shared utility)
	WHERE:        ReplicatedStorage/Shared/Util/AnimalMath
	DEPENDENCIES: Shared.Config.AnimalConfig

	Animal care computed lazily from timestamps (spec §101, §114): no
	per-animal loops, offline time handled naturally, and the client shows
	exactly what the server will decide.

	Saved animal entry:
		{ AnimalId, UniqueId, Variant, HousingId, Happiness, HappinessAt,
		  FedAt, ProduceReadyAt, PettedAt }
]]

local AnimalConfig = require(script.Parent.Parent.Config.AnimalConfig)

local AnimalMath = {}

export type Entry = {
	AnimalId: string,
	Happiness: number,
	HappinessAt: number?,
	FedAt: number?,
	ProduceReadyAt: number?,
	PettedAt: number?,
}

local FULL_SECONDS = AnimalConfig.FullnessDurationMinutes * 60

function AnimalMath.GetFullness(entry: Entry, now: number): number
	local fedAt = entry.FedAt or 0
	if fedAt <= 0 then
		return 0
	end
	return math.clamp(100 - (now - fedAt) / FULL_SECONDS * 100, 0, 100)
end

function AnimalMath.GetHappiness(entry: Entry, now: number): number
	local base = math.clamp(entry.Happiness or AnimalConfig.StartHappiness, 0, 100)
	local since = entry.HappinessAt or now
	local fedAt = entry.FedAt or 0
	-- Happiness only drains once the animal is hungry.
	local hungrySince = if fedAt > 0 then fedAt + FULL_SECONDS * (1 - AnimalConfig.HungryBelow / 100) else since
	local decayFrom = math.max(since, hungrySince)
	if now <= decayFrom or base <= AnimalConfig.HappinessFloor then
		return base
	end
	local decayed = base - (now - decayFrom) / 60 * AnimalConfig.HappinessDecayPerMinute
	return math.max(AnimalConfig.HappinessFloor, decayed)
end

-- "Ready" (product waiting), "Producing", or "Hungry" (feed to start the next batch).
function AnimalMath.GetStatus(entry: Entry, now: number): string
	local readyAt = entry.ProduceReadyAt or 0
	if readyAt > 0 then
		return if now >= readyAt then "Ready" else "Producing"
	end
	return "Hungry"
end

-- Happier animals produce faster (1.0x at 100%, 1.4x slower at 0%).
function AnimalMath.ProduceDuration(animalId: string, happiness: number): number
	local def = AnimalConfig.Animals[animalId]
	if not def then
		return 60
	end
	return def.ProduceTime * (1.4 - 0.4 * math.clamp(happiness, 0, 100) / 100)
end

return AnimalMath
