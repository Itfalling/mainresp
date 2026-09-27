--[[
	SCRIPT NAME:  SoundConfig
	SCRIPT TYPE:  ModuleScript (shared config)
	WHERE:        ReplicatedStorage/Shared/Config/SoundConfig
	DEPENDENCIES: Shared.Util.TableUtil

	!!! EVERY Id BELOW IS A PLACEHOLDER — NO REAL SOUNDS SHIP WITH THIS PROJECT !!!
	Placeholder sounds are silently skipped (AudioController logs them once in
	Debug mode). Paste real "rbxassetid://<number>" ids from the Creator Store
	or your own uploads — see docs/ASSETS.md.

	Each important action has its OWN entry (spec §149: don't reuse one sound
	for everything) even though they are all placeholders today.
]]

local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local PLACEHOLDER = "rbxassetid://PLACEHOLDER"

local function sound(category: string, volume: number?, extra: { [string]: any }?)
	local def = {
		Id = PLACEHOLDER,
		Category = category,
		Volume = volume or 0.6,
		PlaybackSpeed = 1,
		PitchVariation = 0.05, -- random +/- speed so repeated hits don't sound robotic
		RollOffMaxDistance = 80,
	}
	if extra then
		for key, value in extra do
			def[key] = value
		end
	end
	return def
end

local SoundConfig = {
	-- Category volume mixers (multiplied with player settings in later phases).
	Categories = {
		UI = 0.8,
		Coins = 0.8,
		Tools = 0.9,
		Building = 0.9,
		Farming = 0.9,
		Fishing = 0.9,
		Animals = 0.8,
		Environment = 0.5,
		Progress = 1,
		Rewards = 1,
	},

	Sounds = {
		-- UI
		UIClick = sound("UI", 0.5, { PitchVariation = 0 }),
		UIOpen = sound("UI", 0.5),
		UIClose = sound("UI", 0.5),
		UINotify = sound("UI", 0.5),
		UIError = sound("UI", 0.5),

		-- Coins / rewards
		CoinGain = sound("Coins", 0.6),
		CoinSpend = sound("Coins", 0.5),
		ItemGain = sound("Rewards", 0.4),
		RareReward = sound("Rewards", 0.9, { PitchVariation = 0 }),

		-- Progression
		LevelUp = sound("Progress", 0.9, { PitchVariation = 0 }),
		IslandLevelUp = sound("Progress", 1, { PitchVariation = 0 }),
		AreaUnlock = sound("Progress", 1, { PitchVariation = 0 }),
		ChestOpen = sound("Rewards", 0.8),
		QuestComplete = sound("Progress", 0.8),

		-- Tools
		ToolEquip = sound("Tools", 0.5),
		AxeSwing = sound("Tools"),
		PickaxeSwing = sound("Tools"),
		HammerSwing = sound("Tools"),
		ShovelDig = sound("Tools"),
		HoeTill = sound("Tools"),
		Shears = sound("Tools"),
		WoodHit = sound("Tools", 0.7),
		TreeFall = sound("Tools", 0.9),
		RockHit = sound("Tools", 0.7),
		RockBreak = sound("Tools", 0.9),

		-- Building
		HammerHit = sound("Building"),
		WoodPlace = sound("Building"),
		StonePlace = sound("Building"),
		Saw = sound("Building"),
		Paint = sound("Building"),
		ConstructionStart = sound("Building"),
		BuildComplete = sound("Building", 0.9, { PitchVariation = 0 }),
		PlaceInvalid = sound("Building", 0.5),

		-- Farming
		PlantSeed = sound("Farming"),
		Watering = sound("Farming"),
		Harvest = sound("Farming"),

		-- Fishing
		FishingCast = sound("Fishing"),
		FishBite = sound("Fishing"),
		Reel = sound("Fishing", 0.4),
		FishCatch = sound("Fishing"),
		FishEscape = sound("Fishing"),

		-- Animals
		Feed = sound("Animals"),
		Milk = sound("Animals"),
		Pet = sound("Animals"),
		CowMoo = sound("Animals", 0.7),
		ChickenCluck = sound("Animals", 0.6),

		-- Crafting
		CraftHit = sound("Building"),
		CraftComplete = sound("Rewards"),

		-- Ambience (looped; used by the ambience system in Phase 13/18)
		AmbienceOcean = sound("Environment", 0.4, { Looped = true, PitchVariation = 0 }),
		AmbienceBirds = sound("Environment", 0.3, { Looped = true, PitchVariation = 0 }),
		AmbienceWind = sound("Environment", 0.25, { Looped = true, PitchVariation = 0 }),
		AmbienceNight = sound("Environment", 0.3, { Looped = true, PitchVariation = 0 }),
	},
}

return TableUtil.DeepFreeze(SoundConfig)
